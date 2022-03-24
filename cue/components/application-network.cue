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
			app: context.appName
			namespace: context.namespace
			accountname: context.appName // to be deleted?
			streams: parameter.streams
			imports: []
			participants: {[string]: string}
		}
	}
	parameter: {
		// +usage=Specify the streams to be created for the network.
		streams?: [...{
			// +usage=Subject defines the subjects of the stream
			subjects: [...string]
			// +usage=Public defines if the stream shall be exported
			public?: bool
			// +usage=Global defines if the stream is local only or global
			global?: bool
			// +usage=Streams are stored on the server, this can be one of many backends and all are usable in clustering mode.
			// +usage=Allowed values are: file, memory
			storage?: string
			// +usage=
			retention?: string
			// +usage=
			maxMsgsPerSubject?: int64
			// +usage=
			maxMsgs?: int64
			// +usage=
			maxBytes?: int64
			// +usage=
			maxAge?: string
			// +usage=
			maxMsgSize?: int64
			// +usage=
			discard?: string
		}]
	}
}
