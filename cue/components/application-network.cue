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
		apiVersion: "network.edgefarm.io/v1alpha1"
		kind:       "Network"
		spec: {
			namespace: context.namespace
			accountname: context.appName
			usernames: parameter.usernames
		}
	}
	parameter: {
		// +usage=Specify the usernames to be used for the network.
		usernames: [...string]
	}
}
