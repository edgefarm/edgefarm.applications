# edge-app examples

# edge-app

This example shows how to define a single application running on the edge runtime only.
It runs a simple Nginx web server only on edge runtimes that have both labels `mynode` and `cheesebread` set.
The specified edge-worker resource `edge-application1` is labeled with `app: edge-application1`.

See the [edge-app.yaml](edge-app.yaml) for details.

# edge-app-network

This example is very similar to `edge-app` but on top introduces the `network` field which allows to define which application can communicate through `edgefarm.network`. The name in the usernames field must match with the name of the component of type `edge-worker`.

See the [edge-app-network.yaml](edge-app-network.yaml) for details.

# edge-app-network-no-runtimes

This example is very similar to `edge-app-network` but removes the `runtimes` field from the specification. This means that the application will be deployed on all edge runtimes.

See the [edge-app-network-no-runtimes.yaml](edge-app-network-no-runtimes.yaml) for details.