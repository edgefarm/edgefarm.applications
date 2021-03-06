"cloud-network-participant": {
    type: "trait"
    annotations: {}
    labels: {
    }
    description: "Add network-participant on application for specific component that runs in the cloud."
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
                    type: "cloud"
                }
            }
        }
    }
    patch: {
        metadata: {
            annotations: {
                "secret.reloader.stakater.com/reload": context.appName+"."+context.name+".dapr"    
            }
        }
        // +patchKey=name
        spec: selector: matchLabels: {
                    for _, n in parameter.networks {
                        "participant.edgefarm.io/\(n)": "\(n)"
                    }
        }
        spec: template:  metadata: {
            labels: {
                for _, n in parameter.networks {
                    "participant.edgefarm.io/\(n)": "\(n)"
                }
            }
        }
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
                                context.name
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