"volumes": {
	type: "trait"
	annotations: {}
	labels: {
	}
	description: "Add volumes on K8s pod for your workload which follows the pod spec in path 'spec.template'."
	attributes: {
		appliesToWorkloads: ["*"]
		podDisruptive: true
	}
}
template: {
	patch: {
		// +patchKey=name
		spec: template: spec: {	
			volumes: [
				for v in parameter.volumes {
					{
						name: v.name
						if v.type == "pvc" {
							persistentVolumeClaim: {
								claimName: v.claimName
							}
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
							emptyDir: {
								medium: v.medium
							}
						}
						if v.type == "hostPath" {
							hostPath: {
      							path: v.path
      							if v.mountType != _|_ {
	  								type: v.mountType
	  							} 
							}
						}
					}
				},
			]
		}
		spec: template: spec: {
				// +patchKey=name
				containers: [{
				volumeMounts: [
					for v in parameter.volumes {
						{
							name: v.name
							mountPath: v.mountPath
							readOnly: v.readOnly
						}
					}
				]
			}]
		}
	}

	parameter: {
		// +usage=Declare volumes and volumeMounts
		volumes?: [...{
			name: string
			// +usage=Specify volume type, options: "pvc","configMap","secret","emptyDir", "hostPath"
			type: "pvc" | "configMap" | "secret" | "emptyDir" | "hostPath"
			if type == "pvc" {
				claimName: string
				readOnly: *false | bool
			}
			if type == "configMap" {
				defaultMode: *420 | int
				cmName:      string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
				readOnly: *false | bool
			}
			if type == "secret" {
				defaultMode: *420 | int
				secretName:  string
				mountPath: string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
				readOnly: *false | bool
			}
			if type == "emptyDir" {
				medium: *"" | "Memory"
				readOnly: *false | bool
			}
			if type == "hostPath" {
				path: string
				mountPath: string
				mountType?: "DirectoryOrCreate" | "Directory" | "FileOrCreate" | "File" | "Socket" | "CharDevice" | "BlockDevice"
				readOnly: *false | bool
			}
		}]
	}

}