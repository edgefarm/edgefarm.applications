# edgefarm.applications

This repository contains the source of the edgefarm.applications custom resource definitions. The crds are defined [CUElang](https://cuelang.org/docs/) and generated using [kubevela](https://kubevela.io/docs/). 

`edgefarm.applications` contains the following resources:
- `edge-worker` (application runtime running on a edge node)
- `main-worker` (application runtime running in the cloud)
- `application-network` (specifies the network connection to ``EdgeFarm.network``)

## Examples

See the [dev/manifests/applications/examples](dev/manifests/applications/examples/README.md) directory for example manifests.

## Development

Run `make help` to see the available commands.
```
$ make help

Usage:
  make [target]
  all                     renders and deploys all templates into the current k8s cluster
  render                  renders all templates
  deploy                  deploys all templates
  test                    test example, e.g. `make test dev/manifests/applications/some-app.yaml`
  edge-worker-render      renders the edge-worker crd
  edge-worker-deploy      deploys the edge-worker crd into the current k8s cluster
  main-worker-render      renders the main-worker crd
  main-worker-deploy      deploys the main-worker crd into the current k8s cluster
  app-network-render      renders the app-network crd
  app-network-deploy      deploys the app-network crd into the current k8s cluster
  install-vela            install kubevela
  help                    show help message
```

### make render
The `make render` command renders all .cue templates to crd yaml files.
### make deploy
The `make deploy` command applies all crd yaml files into the current k8s cluster.
### make test
The `make test` command takes an example yaml to test against the crd. This can be used to manually
inspect the templating result and check if there are any errors in the resulting yaml.
Example:
```
$ make test dev/manifests/applications/cloud-app/cloud-app.yaml
---
# Application(cloud-app) -- Component(cloud-worker-1) 
---

apiVersion: apps/v1
kind: Deployment
metadata:
  annotations: {}
  labels:
    app.oam.dev/appRevision: ""
    app.oam.dev/component: cloud-worker-1
    app.oam.dev/name: cloud-app
    app.oam.dev/namespace: default
    app.oam.dev/resourceType: WORKLOAD
    release: stable
    workload.oam.dev/type: main-worker
  name: cloud-worker-1
  namespace: default
spec:
  selector:
    matchLabels:
      app.oam.dev/component: cloud-worker-1
  template:
    metadata:
      labels:
        app.oam.dev/component: cloud-worker-1
        release: stable
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions: []
      containers:
      - image: nginx
        name: cloud-worker-1

---

```
### Others make commands
The other commands are pretty self explainatory.
