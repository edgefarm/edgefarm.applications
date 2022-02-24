# mixed-app examples

# mixed-app

This example shows how to define a mixed application running on both edge and cloud runtimes.
It runs one Nginx web server on the cloud runtime and two instances of the same Nginx web server on all edge runtimes. Due to the missing `runtime` field the edge applications are scheduled on each edge runtime.
The specified main-worker resource `cloud-application1` is labeled with `app: cloud-application1`.
The specified edge-worker resource `edge-application1` is labeled with `app: edge-application1`.
The specified edge-worker resource `edge-application2` is labeled with `app: edge-application2`.

See the [mixed-app.yaml](mixed-app.yaml) for details.

# mixed-app-network-volume

This example is very similar to `mixed-app` but on top introduces the `volume` property for `edge-application1`. This property allows to define a volume that will be mounted on the application.

See the [mixed-app-volume.yaml](mixed-app-volume.yaml) for details.