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
		spec: size:     3
	}
	outputs: {}
	parameter: {}
}
