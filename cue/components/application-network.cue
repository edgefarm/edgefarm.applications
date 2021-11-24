"application-network": {
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "network.edgefarm.io/v1alpha1"
		kind:       "Network"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		spec: {
			namespace: context.namespace
			accountname: context.appName
			usernames: ["application-user"]
		}
	}
	parameter: {}
}
