"network-participant": {
    type: "trait"
    annotations: {}
    labels: {
        "ui-hidden": "true"
    }
    description: "Add network-participant on Application for specific component."
    attributes: appliesToWorkloads: ["*"]
}
template: {
    outputs: participant: {
        apiVersion: "network.edgefarm.io/v1alpha1"
        kind:       "Participants"
        metadata: {
            name: context.appName + "." + context.name
            namespace: context.namespace
        }
        spec: {
            component: context.name
            network: parameter.network
        }
    }
    patch: {
        metadata: annotations: {
            {"secret.reloader.stakater.com/reload": context.name+".dapr"    }
        }

        // +patchKey=name
        spec: template: spec: {    
            volumes: [
                {
                    name: "nats-credentials",
                    secret:
                        secretName: context.appName
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
                        secretName: context.appName+".dapr"
                }
            ]
        }
        spec: template: spec: {
                // +patchKey=name
                containers: [{
                            "name":  "nats-leafnode-sidecar",
                            "image": "ci4rail/nats-leafnode-client:4170ee22",
                            "command":  ["/bin/sh", "-c", "/client --natsuri nats://nats.nats:4222 --creds /nats-credentials --component "+context.name],
                            "volumeMounts": [
                                {
                                    "name": "nats-credentials",
                                    "mountPath": "/nats-credentials",
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
                        }]
        }
    }

    parameter:     {
        network: string
        // +usage=Define, which protocol to use for dapr subscriptions, options: "grpc", "http". Defaults to "grpc".
        daprProtocol: *"grpc" | "http"
    }
}