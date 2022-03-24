"edge-network-participant": {
    type: "trait"
    annotations: {}
    labels: {
    }
    description: "Add network-participant on application for specific component that runs on the edge device."
    attributes: {
        appliesToWorkloads: ["*"]
        podDisruptive: true
    }
}
template: {
    outputs: {
        for k, n in parameter.networks {
		    "\(k)": {
                apiVersion: "network.edgefarm.io/v1alpha1"
                kind:       "Participants"
                metadata: {
                    name: context.appName + "." + n + "." + context.name 
                    namespace: context.namespace
                }
                spec: {
                    component: context.name
                    network: n
                    app: context.appName
                    type: "edge"
                }
            }
        }
    }
    patch: {
        metadata: annotations: {
            {"secret.reloader.stakater.com/reload": context.appName+"."+context.name+".dapr"    }
        }

        // +patchKey=name
        spec: template: spec: {
            volumes: [
                {
                    name: "creds",
                    secret:
                        secretName: context.appName+"."+context.name
                },
                {
                    name: "resolv", 
                    hostPath:
                        path: "/etc/resolv.conf"
                        type: "File"
                },
                {
                    name: "dapr-components", 
                    secret:
                        secretName: context.appName+"."+context.name+".dapr"
                }
            ]
        }
        spec: template: spec: {
                // +patchKey=name
                containers: [{
                                "volumeMounts": [{
                                    "name": "creds"
                                    "mountPath": "/nats-credentials"
                                }]
                            },
                            {
                            "name":  "nats-leafnode-sidecar",
                            "image": "ci4rail/nats-leafnode-client:528ef57d",
                            "command":  ["/bin/sh", "-c", "/client --natsuri nats://nats.nats:4222 --creds /creds --component "+context.name],
                            "volumeMounts": [
                                {
                                    "name": "creds",
                                    "mountPath": "/creds",
                                    "readOnly": true
                                },
                                {
                                    "name": "resolv",
                                    "mountPath": "/etc/resolv.conf",
                                    "readOnly": true
                                }
                            ],
                        },
                        {
                            "name":  "dapr",
                            "image": "daprio/daprd:nightly-2022-03-13",
                            "command":  [
                                "./daprd", 
                                "--dapr-grpc-port", 
                                "3500", 
                                "--components-path", 
                                "/components", 
                                "--dapr-http-port", 
                                "3501", 
                                "--app-port", 
                                "50001", 
                                "--app-protocol", 
                                parameter.daprProtocol, 
                                "--app-id",
                                context.name,
                                "--log-level", 
                                "debug"
                            ],
                            "volumeMounts": [
                                {
                                    "name": "dapr-components",
                                    "mountPath": "/components",
                                    "readOnly": true
                                }
                            ]
                        }
                        ]
        }
    }

    parameter: {
        networks: [...string]
        // +usage=Define, which protocol to use for dapr subscriptions, options: "grpc", "http". Defaults to "grpc".
        daprProtocol: *"grpc" | "http"
    }
}