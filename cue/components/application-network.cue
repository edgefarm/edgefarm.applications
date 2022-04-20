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
			streams: parameter.streams
			subjects: parameter.subjects
		}
		info: {
			participating: {
				components: {}
				nodes: {}
				pods: {}
				podsCreating: {}
				podsTerminating: {}
			}
			mainDomain: {
				standard: {}
				mirror: {}
				aggregate: {}
			}
			usedAccount: ""
		}
	}
	parameter: {
		// +usage=Subject defines the subjects of the network
		subjects: [...{
			// +usage=name defines the name of the subject
			name: string
			// +usage=subject defines the subject
			subjects: [...string]
			// +usage=stream defines the stream name for the subject
			stream: string
		}]

		// +usage=Specify the streams to be created for the network.
		streams: [...{
			// +usage=name defines the name of the stream
			name: string
			// +usage=location defines where the stream is located
			// +usage=Allowed values are: node, main
			// +required
			// +default="node"
			location: string
			// +usage=link defines if the stream is linked to another stream
			link?: {
				// +usage=stream defines the name of the linked stream
				stream: string
			}
			// +usage=config defines the configuration of the stream
			config: {
				// +usage=Streams are stored on the server, this can be one of many backends and all are usable in clustering mode.
				// +usage=Allowed values are: file, memory
				storage?: string
				// +usage=Messages are retained either based on limits like size and age (Limits), as long as there are Consumers (Interest) or until any worker processed them (Work Queue)
				// +usage=Allowed values are: limits, interest, workqueue
				// +default="limits"
				retention?: string
				// +usage=MaxMsgsPerSubject defines the amount of messages to keep in the store for this Stream per unique subject, when exceeded oldest messages are removed, -1 for unlimited.
				// +default=-1
				maxMsgsPerSubject?: int64
				// +usage=MaxMsgs defines the amount of messages to keep in the store for this Stream, when exceeded oldest messages are removed, -1 for unlimited.
				// +default=-1
				maxMsgs?: int64
				// +usage=MaxBytes defines the combined size of all messages in a Stream, when exceeded oldest messages are removed, -1 for unlimited.
				// +default=-1
				maxBytes?: int64
				// +usage=MaxAge defines the oldest messages that can be stored in the Stream, any messages older than this period will be removed, -1 for unlimited. Supports units (s)econds, (m)inutes, (h)ours, (d)ays, (M)onths, (y)ears.
				// +default="1y"
				maxAge?: string
				// +usage=MaxMsgSize defines the maximum size any single message may be to be accepted by the Stream.
				// +default=-1
				maxMsgSize?: int64
				// +usage=
				// +default="old"
				discard?: string
			}
		}]
	}
}
