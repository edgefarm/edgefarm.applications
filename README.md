[contributors-shield]: https://img.shields.io/github/contributors/edgefarm/edgefarm.application.svg?style=for-the-badge
[contributors-url]: https://github.com/edgefarm/edgefarm.application/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/edgefarm/edgefarm.application.svg?style=for-the-badge
[forks-url]: https://github.com/edgefarm/edgefarm.application/application/members
[stars-shield]: https://img.shields.io/github/stars/edgefarm/edgefarm.application.svg?style=for-the-badge
[stars-url]: https://github.com/edgefarm/edgefarm.application/stargazers
[issues-shield]: https://img.shields.io/github/issues/edgefarm/edgefarm.application.svg?style=for-the-badge
[issues-url]: https://github.com/edgefarm/edgefarm.application/issues
[license-shield]: https://img.shields.io/github/license/edgefarm/edgefarm.application?logo=mit&style=for-the-badge
[license-url]: https://opensource.org/licenses/AGPL-3.0

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![AGPL 3.0 License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/edgefarm/edgefarm.application">
    <img src="https://github.com/edgefarm/edgefarm/raw/beta/.images/EdgefarmLogoWithText.png" alt="Logo" height="112">
  </a>

  <h2 align="center">edgefarm.applications</h2>

  <p align="center">
    Easy way of managing applications for EdgeFarm.
  </p>
  <hr />
</p>

# About The Project

Dealing with workload definitions can be painful. Especially when it comes to combining different workloads and managing them in a cluster. `EdgeFarm.applications` is a custom resource definition (CRD) that allows you to define your EdgeFarm application in a single file and deploy it to your cluster.

`EdgeFarm.applications` uses the open source project kubevela under the hood for this, a swiss army knife for managing workload specifiations. The CRDs are defined using [CUElang](https://cuelang.org/docs/) and generated using [kubevela](https://kubevela.io/docs/). It also has a dependency on [OpenYurt](https://github.com/openyurtio/openyurt) with its corresponding CRDs to generate the correct workload definitions needed for `EdgeFarm.core`.

## Features

 - Easy definition of complex applications in a single file
 - Connect your application to a `EdgeFarm.network` with a [dapr](https://dapr.io) sidecar container

# Getting Started

Follow those simple steps, to provision `EdgeFarm.applications` in your local cluster based on `EdgeFarm.core`.

## ✔️ Prerequisites

- [(local kind) cluster running edgefarm.core](https://github.com/edgefarm/edgefarm.core)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## ⚙️ Configuration

TODO

## 🎯 Installation

You can deploy `EdgeFarm.applications` to your cluster using devspace or kustomize. 

### Deploy using devspace

```console
$ devspace run help
Usage of edgefarm.core:
 EdgeFarm related commands:
  devspace run-pipeline deploy                    Deploy the edgefarm.applications stack

$ devspace run-pipeline deploy
# ....
```

### Deploy using kustomize

```console
$ kustomize build --enable-helm manifests/vela-system | kubectl apply -f -
$ kustomize build --enable-helm manifests/vela-caps | kubectl apply -f -
```

## 🧪 Testing

You can simply test the installation by deploying the example application.

```console
$ kubectl apply -n default -f examples/pure.yaml
application.core.oam.dev/pure created
```

Then label the nodepool the workload should be deployed to.

```console
$ kubectl get nodes
NAME                    STATUS   ROLES                  AGE     VERSION
jakku-control-plane-1   Ready    control-plane,master   9d      v1.22.17
jakku-control-plane-2   Ready    control-plane,master   9d      v1.22.17
jakku-master            Ready    control-plane,master   9d      v1.22.17
jakku-worker-1          Ready    <none>                 3d22h   v1.22.17

$ kubectl get nodepools.apps.openyurt.io              
NAME     TYPE    READYNODES   NOTREADYNODES   AGE
edge     Edge    0            0               6d21h
master   Cloud   3            0               8d
worker   Cloud   1            0               8d

$ kubectl label nodepools.apps.openyurt.io worker app/pure=
nodepool.apps.openyurt.io/worker labeled
```

The example application should be deployed to the worker node.

```
$ kubectl get pods -n default -l app.kubernetes.io/app=pure -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP            NODE             NOMINATED NODE   READINESS GATES
pure-worker-5rkmg-56c55859bd-vlt8j   1/1     Running   0          42s   10.244.6.83   jakku-worker-1   <none>           <none>
```

# 💡 Usage

Simply write your application definition and deploy it to your cluster.

# 📖 Examples

Please have a look at the [examples](examples) directory in this repository.

# 🐞 Developing and debugging

If you like to develop and debug this project make use of the makefile. 

```console
$ make help

Usage:
  make [target]
  all                     renders and deploys all templates into the current k8s cluster
  render                  renders all templates
  apply                   applies all templates
  deploy                  deploys all templates
  test                    test example, e.g. `make test dev/manifests/applications/some-app.yaml`
  traits-render           renders all traits
  traits-apply            applies all traits using vela cli
  traits-deploy           deploys all traits using kubectl
  components-render       renders all components
  components-apply        applies all components using vela cli
  components-deploy       deploys all components using kubectl
  install-vela            install kubevela
  help                    show help message
```

Kubevela will tell you what's wrong. The `make test` command takes an example yaml to test against the CRD. This can be used to manually
inspect the templating result and check if there are any errors in the resulting yaml.

```console
$ make test examples/pure.yaml
---
# Application(pure) -- Component(pure) 
---

apiVersion: apps.openyurt.io/v1alpha1
kind: YurtAppDaemon
metadata:
  annotations: {}
  labels:
    app.oam.dev/appRevision: ""
    app.oam.dev/component: pure
    app.oam.dev/name: pure
    app.oam.dev/namespace: default
    app.oam.dev/resourceType: WORKLOAD
    workload.oam.dev/type: edgefarm-applications
  name: pure
  namespace: default
spec:
  nodepoolSelector:
    matchLabels:
      app/pure: ""
  selector:
    matchLabels:
      app.kubernetes.io/app: pure
      app.kubernetes.io/component: pure
  workloadTemplate:
    deploymentTemplate:
      metadata:
        labels:
          app.kubernetes.io/app: pure
          app.kubernetes.io/component: pure
      spec:
        replicas: 1
        selector:
          matchLabels:
            app.kubernetes.io/app: pure
            app.kubernetes.io/component: pure
        template:
          metadata:
            labels:
              app.kubernetes.io/app: pure
              app.kubernetes.io/component: pure
          spec:
            containers:
            - command:
              - sh
              - -c
              - sleep infinity
              image: bash:5.1-alpine3.17
              name: pure
              resources: {}

---


make: Nothing to be done for 'examples/pure.yaml'.
```

# 🤝🏽 Contributing

Code contributions are very much **welcome**.

1. Fork the Project
2. Create your Branch (`git checkout -b AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature")
4. Push to the Branch (`git push origin AmazingFeature`)
5. Open a Pull Request targetting the `beta` branch.

# 🫶 Acknowledgements

Thanks to kubevela for providing a great framework to build on top of.
