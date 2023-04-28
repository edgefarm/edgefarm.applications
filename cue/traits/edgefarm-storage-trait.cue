"edgefarm-storage": {
	type: "trait"
	annotations: {}
	labels: {}
	description: "Add storages to edgefarm.applications workload."
	attributes: {
		appliesToWorkloads: ["yurtappdaemons.apps"]
		podDisruptive: true
	}
}
template: {
	volumesList: [
		if parameter.configMap != _|_ for v in parameter.configMap if v.mountPath != _|_ {
			{
				name: "configmap-" + v.name
				configMap: {
					defaultMode: v.defaultMode
					name:        v.name
					if v.items != _|_ {
						items: v.items
					}
				}
			}
		},
		if parameter.secret != _|_ for v in parameter.secret if v.mountPath != _|_ {
			{
				name: "secret-" + v.name
				secret: {
					defaultMode: v.defaultMode
					secretName:  v.name
					if v.items != _|_ {
						items: v.items
					}
				}
			}
		},
		if parameter.emptyDir != _|_ for v in parameter.emptyDir {
			{
				name: "emptydir-" + v.name
				emptyDir: {
					medium: v.medium
				}
			}
		},
		if parameter.hostPath != _|_ for v in parameter.hostPath {
			{
				name: "hostpath-" + v.name
				path: v.path
			}
		},
	]

	volumeMountsList: [
		if parameter.configMap != _|_ for v in parameter.configMap if v.mountPath != _|_ {
			{
				name:      "configmap-" + v.name
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
			}
		},
		if parameter.secret != _|_ for v in parameter.secret if v.mountPath != _|_ {
			{
				name:      "secret-" + v.name
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
			}
		},
		if parameter.emptyDir != _|_ for v in parameter.emptyDir {
			{
				name:      "emptydir-" + v.name
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
			}
		},
		if parameter.hostPath != _|_ for v in parameter.hostPath {
			{
				name:      "hostpath-" + v.name
				mountPath: v.mountPath
			}
		},
	]

	envList: [
		if parameter.configMap != _|_ for v in parameter.configMap if v.mountToEnv != _|_ {
			{
				name: v.mountToEnv.envName
				valueFrom: configMapKeyRef: {
					name: v.name
					key:  v.mountToEnv.configMapKey
				}
			}
		},
		if parameter.configMap != _|_ for v in parameter.configMap if v.mountToEnvs != _|_ for k in v.mountToEnvs {
			{
				name: k.envName
				valueFrom: configMapKeyRef: {
					name: v.name
					key:  k.configMapKey
				}
			}
		},
		if parameter.secret != _|_ for v in parameter.secret if v.mountToEnv != _|_ {
			{
				name: v.mountToEnv.envName
				valueFrom: secretKeyRef: {
					name: v.name
					key:  v.mountToEnv.secretKey
				}
			}
		},
		if parameter.secret != _|_ for v in parameter.secret if v.mountToEnvs != _|_ for k in v.mountToEnvs {
			{
				name: k.envName
				valueFrom: secretKeyRef: {
					name: v.name
					key:  k.secretKey
				}
			}
		},
	]

	deDupVolumesArray: [
		for val in [
			for i, vi in volumesList {
				for j, vj in volumesList if j < i && vi.name == vj.name {
					_ignore: true
				}
				vi
			},
		] if val._ignore == _|_ {
			val
		},
	]
	patch: {
		spec: workloadTemplate: deploymentTemplate: spec: template: spec: {
			// +patchKey=name
            // +patchStrategy=retainKeys
			volumes: deDupVolumesArray

			// +patchKey=name	
			containers: [{
				// +patchKey=name
				env: envList
				// +patchKey=name
				volumeMounts: volumeMountsList
			}, ...]
		}
	}
	outputs: {
		for v in parameter.configMap {
			if v.mountOnly == false {
				"configmap-\(v.name)": {
					apiVersion: "v1"
					kind:       "ConfigMap"
					metadata: name: v.name
					if v.data != _|_ {
						data: v.data
					}
				}
			}
		}

		for v in parameter.secret {
			if v.mountOnly == false {
				"secret-\(v.name)": {
					apiVersion: "v1"
					kind:       "Secret"
					metadata: name: v.name
					if v.data != _|_ {
						data: v.data
					}
					if v.stringData != _|_ {
						stringData: v.stringData
					}
				}
			}
		}
	}

	parameter: {
		// +usage=Declare config map type storage
		configMap?: [...{
			name:      string
			mountOnly: *false | bool
			mountToEnv?: {
				envName:      string
				configMapKey: string
			}
			mountToEnvs?: [...{
				envName:      string
				configMapKey: string
			}]
			mountPath?:  string
			subPath?:    string
			defaultMode: *420 | int
			readOnly:    *false | bool
			data?: {...}
			items?: [...{
				key:  string
				path: string
				mode: *511 | int
			}]
		}]

		// +usage=Declare secret type storage
		secret?: [...{
			name:      string
			mountOnly: *false | bool
			mountToEnv?: {
				envName:   string
				secretKey: string
			}
			mountToEnvs?: [...{
				envName:   string
				secretKey: string
			}]
			mountPath:   string
			subPath?:    string
			defaultMode: *420 | int
			readOnly:    *false | bool
			stringData?: {...}
			data?: {...}
			items?: [...{
				key:  string
				path: string
				mode: *511 | int
			}]
		}]

		// +usage=Declare empty dir type storage
		emptyDir?: [...{
			name:      string
			mountPath: string
			subPath?:  string
			medium:    *"" | "Memory"
		}]

		// +usage=Declare host path type storage
		hostPath?: [...{
			name:      string
			path:      string
			mountPath: string
			type:      *"Directory" | "DirectoryOrCreate" | "FileOrCreate" | "File" | "Socket" | "CharDevice" | "BlockDevice"
		}]
	}

}