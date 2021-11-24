"edge-worker": {
	type: "component"
	annotations: {}
	labels: {}
	description: "Describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic."
	attributes: workload: definition: {
		apiVersion: "apps/v1"
		kind:       "DaemonSet"
	}
}
template: {
	output: {
		apiVersion: "apps/v1"
		kind:       "DaemonSet"
		spec: {
			selector: matchLabels: "app.oam.dev/component": context.name

			template: {
				metadata: labels: "app.oam.dev/component": context.name

				spec: {
					containers: [{
						name:  context.name
						image: parameter.image

						if parameter["imagePullPolicy"] != _|_ {
							imagePullPolicy: parameter.imagePullPolicy
						}

						if parameter["cmd"] != _|_ {
							command: parameter.cmd
						}

						if parameter["env"] != _|_ {
							env: parameter.env
						}

						if parameter["cpu"] != _|_ {
							resources: {
								limits: cpu:   parameter.cpu
								requests: cpu: parameter.cpu
							}
						}

						if parameter["memory"] != _|_ {
							resources: {
								limits: memory:   parameter.memory
								requests: memory: parameter.memory
							}
						}

						if parameter["volumes"] != _|_ {
							volumeMounts: [ for v in parameter.volumes {
								{
									mountPath: v.mountPath
									name:      v.name
								}}]
						}

						if parameter["livenessProbe"] != _|_ {
							livenessProbe: parameter.livenessProbe
						}

						if parameter["readinessProbe"] != _|_ {
							readinessProbe: parameter.readinessProbe
						}

					}]

					if parameter["imagePullSecrets"] != _|_ {
						imagePullSecrets: [ for v in parameter.imagePullSecrets {
							name: v
						},
						]
					}

					if parameter["volumes"] != _|_ {
						volumes: [ for v in parameter.volumes {
							{
								name: v.name
								if v.type == "pvc" {
									persistentVolumeClaim: claimName: v.claimName
								}
								if v.type == "configMap" {
									configMap: {
										defaultMode: v.defaultMode
										name:        v.cmName
										if v.items != _|_ {
											items: v.items
										}
									}
								}
								if v.type == "secret" {
									secret: {
										defaultMode: v.defaultMode
										secretName:  v.secretName
										if v.items != _|_ {
											items: v.items
										}
									}
								}
								if v.type == "emptyDir" {
									emptyDir: medium: v.medium
								}
							}}]
					}
					affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
						matchExpressions: [
						{
							key: "node-role.kubernetes.io/edge"
							operator: "Exists"
						},
						{
							key: "node-role.kubernetes.io/agent"
							operator: "Exists"
						}
						]
					}]

					tolerations: [
						{
							key: "edgefarm.applications"
							operator: "Exists"
							effect: "NoExecute"
						}
					]
				}
			}
		}
	}

	parameter: {
		// +usage=Which image would you like to use for your service
		// +short=i
		image: string

		// +usage=Specify image pull policy for your service
		imagePullPolicy?: string

		// +usage=Specify image pull secrets for your service
		imagePullSecrets?: [...string]

		// +usage=Commands to run in the container
		cmd?: [...string]

		// +usage=Define arguments by using environment variables
		env?: [...{
			// +usage=Environment variable name
			name: string
			// +usage=The value of the environment variable
			value?: string
			// +usage=Specifies a source the value of this var should come from
			valueFrom?: {
				// +usage=Selects a key of a secret in the pod's namespace
				secretKeyRef: {
					// +usage=The name of the secret in the pod's namespace to select from
					name: string
					// +usage=The key of the secret to select from. Must be a valid secret key
					key: string
				}
			}
		}]

		// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
		cpu?: string

		// +usage=Specifies the attributes of the memory resource required for the container.
		memory?: string

		// +usage=Declare volumes and volumeMounts
		volumes?: [...{
			name:      string
			mountPath: string
			// +usage=Specify volume type, options: "pvc","configMap","secret","emptyDir"
			type: "pvc" | "configMap" | "secret" | "emptyDir"
			if type == "pvc" {
				claimName: string
			}
			if type == "configMap" {
				defaultMode: *420 | int
				cmName:      string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}
			if type == "secret" {
				defaultMode: *420 | int
				secretName:  string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}
			if type == "emptyDir" {
				medium: *"" | "Memory"
			}
		}]

		// +usage=Instructions for assessing whether the container is alive.
		livenessProbe?: #HealthProbe

		// +usage=Instructions for assessing whether the container is in a suitable state to serve traffic.
		readinessProbe?: #HealthProbe
	}

	#HealthProbe: {

		// +usage=Instructions for assessing container health by executing a command. Either this attribute or the httpGet attribute or the tcpSocket attribute MUST be specified. This attribute is mutually exclusive with both the httpGet attribute and the tcpSocket attribute.
		exec?: {
			// +usage=A command to be executed inside the container to assess its health. Each space delimited token of the command is a separate array element. Commands exiting 0 are considered to be successful probes, whilst all other exit codes are considered failures.
			command: [...string]
		}

		// +usage=Instructions for assessing container health by executing an HTTP GET request. Either this attribute or the exec attribute or the tcpSocket attribute MUST be specified. This attribute is mutually exclusive with both the exec attribute and the tcpSocket attribute.
		httpGet?: {
			// +usage=The endpoint, relative to the port, to which the HTTP GET request should be directed.
			path: string
			// +usage=The TCP socket within the container to which the HTTP GET request should be directed.
			port: int
			httpHeaders?: [...{
				name:  string
				value: string
			}]
		}

		// +usage=Instructions for assessing container health by probing a TCP socket. Either this attribute or the exec attribute or the httpGet attribute MUST be specified. This attribute is mutually exclusive with both the exec attribute and the httpGet attribute.
		tcpSocket?: {
			// +usage=The TCP socket within the container that should be probed to assess container health.
			port: int
		}

		// +usage=Number of seconds after the container is started before the first probe is initiated.
		initialDelaySeconds: *0 | int

		// +usage=How often, in seconds, to execute the probe.
		periodSeconds: *10 | int

		// +usage=Number of seconds after which the probe times out.
		timeoutSeconds: *1 | int

		// +usage=Minimum consecutive successes for the probe to be considered successful after having failed.
		successThreshold: *1 | int

		// +usage=Number of consecutive failures required to determine the container is not alive (liveness probe) or not ready (readiness probe).
		failureThreshold: *3 | int
	}
}