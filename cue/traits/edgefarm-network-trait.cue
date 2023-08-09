"edgefarm-network": {
    type: "trait"
    annotations: {}
    labels: {
    }
    description: "Add edgefarm.network participation to a edgefarm.applications workload"
    attributes: {
        appliesToWorkloads: ["yurtappdaemons.apps"]
        podDisruptive: true
    }
}
template: {
    patch: {
        spec: workloadTemplate: deploymentTemplate: {
            metadata: annotations: {
                "reloader.stakater.com/auto": "true"
            }
            spec: template: {
                spec: {
                    // +patchKey=name
                    // +patchStrategy=retainKeys
                    volumes: [
                        {
                            name: "secret-"+parameter.network.name+"-"+parameter.network.user,
                            secret:
                                secretName: parameter.network.name+"-"+parameter.network.user
                        },
                        {
                            name: "config"+parameter.network.name+"-"+parameter.network.user,
                            emptyDir: {}
                        },
                        {
                            name: "dapr-resiliency"
                            configMap:
                                name: "resiliency-"+parameter.network.name+"-"+parameter.network.user+"-"+context.name
                        },
                    ]
                    initContainers: [{
                        command: ["sh", "-c", "cp /secret/dapr /config/streams.yaml && sed -i \"s#localhost#$SUBNETWORK_SVC_ADDRESS.$SUBNETWORK_NAMESPACE#g\" /config/streams.yaml && cat /config/streams.yaml && cp /resiliency-config/resiliency.yaml /config/resiliency.yaml"]
                        env: [{
                            name:  "SUBNETWORK_SVC_ADDRESS"
                            value: parameter.network.name+"-"+context.namespace+"-"+parameter.network.subnetwork
                        }, {
                            name: "SUBNETWORK_NAMESPACE"
                            valueFrom: fieldRef: fieldPath: "metadata.namespace"
                        }]
                        image:           "bash:5.1-alpine3.17"
                        imagePullPolicy: "IfNotPresent"
                        name:            "init-dapr"
                        volumeMounts: [{
                            mountPath: "/config/"
                            name:      "config"+parameter.network.name+"-"+parameter.network.user,
                        }, 
                        {
                            mountPath: "/secret"
                            name:      "secret-"+parameter.network.name+"-"+parameter.network.user
                        },
                        {
                            mountPath: "/resiliency-config"
                            name:      "dapr-resiliency"
                        }]
                    }]
                    // +patchKey=name
                    containers: [{
                        name: context.name,
                        // +patchStrategy=retainKeys
                        volumeMounts: [{
                            name:      "secret-"+parameter.network.name+"-"+parameter.network.user
                            mountPath: "/creds/network.creds"
                            subPath: "creds"
                            readOnly: true
                        }],
                        env: [
                            {
                                name: "DAPR_GRPC_ADDRESS",
                                value: "localhost:\(parameter.daprGrpcPort)"
                            },
                            {
                                name: "DAPR_HTTP_ADDRESS",
                                value: "localhost:\(parameter.daprHttpPort)"
                            },
                            {
                                name: "NODE_NAME",
                                valueFrom:
                                    fieldRef:
                                        fieldPath: "spec.nodeName"
                            },
                        ],
                    },
                    {
                        name:  "dapr",
                        image: "daprio/daprd:1.10.5",
                        command:  [
                            "./daprd",
                            "--dapr-grpc-port",
                            "\(parameter.daprGrpcPort)",
                            "--components-path",
                            "/config",
                            "--dapr-http-port",
                            "\(parameter.daprHttpPort)",
                            "--app-port",
                            "\(parameter.daprAppPort)",
                            "--app-protocol",
                            parameter.daprProtocol,
                            "--app-id",
                            context.name
                        ],
                        volumeMounts: [
                            {
                                "name": "config"+parameter.network.name+"-"+parameter.network.user,
                                "mountPath": "/config/"
                                "readOnly": true
                            }
                        ]
                    }]
                }
            }
        }
    }
    outputs: {
        "resiliency-dapr-component": {
            apiVersion: "v1"
            kind: "ConfigMap"
            metadata: {
                name: "resiliency-"+parameter.network.name+"-"+parameter.network.user+"-"+context.name
            }
            data: {
                "resiliency.yaml": """
                    apiVersion: dapr.io/v1alpha1
                    kind: Resiliency
                    metadata:
                    name: streams
                    spec:
                    policies:
                        retries:
                        retryForever:
                            policy: exponential
                            maxInterval: 15s
                            maxRetries: -1
                        circuitBreakers:
                        pubsubCB:
                            maxRequests: 1
                            interval: 8s
                            timeout: 45s
                            trip: consecutiveFailures > 1
                    targets:
                        components:
                        streams:
                            outbound:
                            retry: retryForever
                            circuitBreaker: simpleCB
                        pubsub1:
                            outbound:
                            retry: pubsubRetry
                            circuitBreaker: pubsubCB
                    """
            }
        }
    }
    parameter: {
        network: 
            name: string
            user: string
            subnetwork: string
        // +usage=Define which protocol to use for dapr connections, options: "grpc", "http". Defaults to "grpc".
        daprProtocol: *"grpc" | "http"
        daprGrpcPort: *3500 | int
        daprHttpPort: *3501 | int
        daprAppPort: *50001 | int
    }
}
