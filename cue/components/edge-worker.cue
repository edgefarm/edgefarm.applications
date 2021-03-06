package stdlib

import "list"

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
			selector: matchLabels: {
						"app.kubernetes.io/component": context.name,
						"app.kubernetes.io/app": context.appName,
						"node-dns.host": context.appName,
					}

			template: {
				metadata: {
					labels: {
						"app.kubernetes.io/component": context.name,
						"app.kubernetes.io/app": context.appName,
						"node-dns.host": context.appName,
					}
				}

				spec: {
					containers: [
						{
							name:  context.name
							image: parameter.image

							if parameter["imagePullPolicy"] != _|_ {
								imagePullPolicy: parameter.imagePullPolicy
							}

							if parameter["command"] != _|_ {
								command: parameter.command
							}

							if parameter["args"] != _|_ {
								args: parameter.args
							}

							if parameter["env"] != _|_ {
								env: parameter.env
							}

							if parameter["ports"] != _|_ {
								ports: parameter.ports
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

							if parameter["livenessProbe"] != _|_ {
								livenessProbe: parameter.livenessProbe
							}

							if parameter["readinessProbe"] != _|_ {
								readinessProbe: parameter.readinessProbe
							}

							if parameter["securityContext"] != _|_ {
								securityContext: parameter.securityContext								
							}
						}

					]

					if parameter["imagePullSecrets"] != _|_ {
						imagePullSecrets: [ for v in parameter.imagePullSecrets {
							name: v
						},
						]
					}

					affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
						matchExpressions: [ 
							for v in list.FlattenN(#MatchExpressions, 1) {
							{
								key: v
								operator: "Exists"
							}}
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

		// +usage=Specify runtimes that shall receive the application. If not specified, the application will be deployed on all runtimes.
		runtime: [...string]
					
		// +usage=Specify image pull policy for your service
		imagePullPolicy?: string

		// +usage=Specify image pull secrets for your service
		imagePullSecrets?: [...string]

		// +usage=Commands to run in the container
		command?: [...string]

		// +usage=Args to run for the command
		args?: [...string]

		// +usage=Specifies the SecurityContext of the container
		securityContext?: {
			allowPrivilegeEscalation?: bool
			capabilities?: {
				add?: [...string]
				drop?: [...string]
			}
			privileged?: bool
			// procMount currently ununsed
			// procMount?: string
			readOnlyRootFilesystem?: bool
			runAsGroup?: int
			runAsNonRoot?: bool
			runAsUser?: int
			// seLinuxOptions currently ununsed
			// seLinuxOptions?: {...}
			// seccompProfile currently ununsed
			// seccompProfile?: {}
			// windowsOptions never used
		}

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

		// +usage=Define arguments by using port mappings
		ports?: [...{
			// +usage=Name of the port mapping
			name?: string
			// +usage=The container port to expose
			containerPort: int
			// +usage=The host port the container port is mapped to
			hostPort: int
			// +usage=The protocol of the port mapping
			protocol?: string
		}]


		// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
		cpu?: string

		// +usage=Specifies the attributes of the memory resource required for the container.
		memory?: string

		// +usage=Instructions for assessing whether the container is alive.
		livenessProbe?: #HealthProbe

		// +usage=Instructions for assessing whether the container is in a suitable state to serve traffic.
		readinessProbe?: #HealthProbe
	}

	// Note: parameter.runtime MUST not be an optional property, otherwise the deployment will fail.
	#MatchExpressions: [ "node-role.kubernetes.io/edge", "node-role.kubernetes.io/agent", parameter.runtime ]

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
