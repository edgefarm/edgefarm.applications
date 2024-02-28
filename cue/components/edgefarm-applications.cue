import "list"

"edgefarm-applications": {
	type: "component"
	annotations: {}
	labels: {}
	description: "Describes an edgefarm.application that runs on EdgeFarm edge nodes."
	attributes: workload: {
		definition: {
			apiVersion: "apps.openyurt.io/v1alpha1"
			kind:       "YurtAppDaemon"
		}
	}
}
template: {
	predefinedTolerations: [
		{
			key: "edgefarm.io",
			operator: "Exists",
			effect: "NoSchedule"
		}
	]

	parameterTolerations: [
	if parameter.tolerations != _|_ {
		for k in parameter.tolerations {
				if k.key != _|_ {
						key: k.key
				}
				if k.effect != _|_ {
						effect: k.effect
				}
				if k.value != _|_ {
						value: k.value
				}
				operator: k.operator
				if k.tolerationSeconds != _|_ {
						tolerationSeconds: k.tolerationSeconds
				}
		} 
	}]

	output: {
		apiVersion: "apps.openyurt.io/v1alpha1"
		kind:       "YurtAppDaemon"
		spec: {
			if parameter["nodepoolSelector"] != _|_ {
			nodepoolSelector: parameter.nodepoolSelector
			}
      				
			selector: {
				matchLabels: {
					"app.kubernetes.io/component": context.name,
					"app.kubernetes.io/app": context.appName,
				}
			}
			workloadTemplate: {
				deploymentTemplate: {
					metadata: {
						labels: {
							"app.kubernetes.io/component": context.name,
							"app.kubernetes.io/app": context.appName,
						}
					}

					spec: {
						replicas: 1
						selector: matchLabels: {
							"app.kubernetes.io/component": context.name,
							"app.kubernetes.io/app": context.appName,
						}
						template: {
							metadata: {
								labels: {
									"app.kubernetes.io/component": context.name,
									"app.kubernetes.io/app": context.appName,
								}
							}
							spec: {
								tolerations: predefinedTolerations + parameterTolerations
								containers: [{
									name:  context.name
									image: parameter.image
									imagePullPolicy: parameter.imagePullPolicy

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

									resources: {
										if parameter.cpu != _|_ if parameter.memory != _|_ if parameter.requests == _|_ if parameter.limits == _|_ {
											// +patchStrategy=retainKeys
											requests: {
												cpu:    parameter.cpu
												memory: parameter.memory
											}
											// +patchStrategy=retainKeys
											limits: {
												cpu:    parameter.cpu
												memory: parameter.memory
											}
										}

										if parameter.requests != _|_ {
											// +patchStrategy=retainKeys
											requests: {
												cpu:    parameter.requests.cpu
												memory: parameter.requests.memory
											}
										}
										if parameter.limits != _|_ {
											// +patchStrategy=retainKeys
											limits: {
												cpu:    parameter.limits.cpu
												memory: parameter.limits.memory
											}
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
								}]

								if parameter["imagePullSecrets"] != _|_ {
									imagePullSecrets: [ for v in parameter.imagePullSecrets {
										name: v
									}]
								}
							}
						}
					}
				}
			}
		}
	}

	#nodepoolSelector: {
		matchLabels?: [string]: string
		matchExpressions?: [...{
			key:      string
			operator: *"In" | "NotIn" | "Exists" | "DoesNotExist"
			values?: [...string]
		}]
	}

	#tolerations: [...{
		key?:     string
		operator: *"Equal" | "Exists"
		value?:   string
		effect?:  "NoSchedule" | "PreferNoSchedule" | "NoExecute"
		// +usage=Specify the period of time the toleration
		tolerationSeconds?: int
	}]


	parameter: {
		// +usage=Which image would you like to use for your application
		image: string

		// +usage=Specify a list of nodepool selectors
		nodepoolSelector: #nodepoolSelector

		// +usage=Specify tolerant taint
		tolerations?: #tolerations

		// +usage=Specify image pull policy for your application
		imagePullPolicy:  *"IfNotPresent" | "Always" | "Never"

		// +usage=Specify image pull secrets for your application
		imagePullSecrets?: [...string]

		// +usage=Commands to run in the container
		command?: [...string]

		// +usage=Args to run for the command
		args?: [...string]

		// +usage=Specifies the SecurityContext of the container
		securityContext?: {
			// +usage=AllowPrivilegeEscalation controls whether a process can gain more privileges than its parent process.
			allowPrivilegeEscalation?: bool
			// +uasge=The capabilities to add/drop when running containers. 
			capabilities?: {
				// +usage=Added capabilities
				add?: [...string]
				// +usage=Dropped capabilities
				drop?: [...string]
			}
			// +usage=Run container in privileged mode. 
			privileged?: bool
			// +usage=Whether this container has a read-only root filesystem.
			readOnlyRootFilesystem?: bool
			// +usage=The GID to run the entrypoint of the container process.
			runAsGroup?: int
			// +usage=Indicates that the container must run as a non-root user.
			runAsNonRoot?: bool
			// +usage=The UID to run the entrypoint of the container process. 
			runAsUser?: int
			// procMount currently ununsed
			// procMount?: string
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
				secretKeyRef?: {
					// +usage=The name of the secret in the pod's namespace to select from
					name: string
					// +usage=The key of the secret to select from. Must be a valid secret key
					key: string
				}
				// +usage=Selects a key of a config map in the pod's namespace
				configMapKeyRef?: {
					// +usage=The name of the config map in the pod's namespace to select from
					name: string
					// +usage=The key of the config map to select from. Must be a valid secret key
					key: string
				}
			}
		}]

		// +usage=Specify port mappings
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


		// +usage=Specify the amount of cpu for requests and limits
		cpu?: *"0.25" | number | string
		// +usage=Specify the amount of memory for requests and limits
		memory?: *"256Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
		// +usage=Specify the resources in requests
		requests?: {
			// +usage=Specify the amount of cpu for requests
			cpu: *"0.25" | number | string
			// +usage=Specify the amount of memory for requests
			memory: *"256Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
		}
		// +usage=Specify the resources in limits
		limits?: {
			// +usage=Specify the amount of cpu for limits
			cpu: *"0.5" | number | string
			// +usage=Specify the amount of memory for limits
			memory: *"512Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
		}

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
