# examples

Here you can find some examples how to define and use edgefarm.applications manifests.

# edge-nats-box.yaml

This example shows how to define a mixed application running on both edge and cloud runtimes.
It runs a nats-box on the edge runtime. Due to the runtime field in the component spec, 
the component will run on all edge runtimes that have the label `mydevice=` set.

This example introduces the `application-network` component which allows to configure the EdgeFarm network for the application. 
The trait `network-participant` defines which component can communicate through the network. 
The specified network has three streams defined.
1. `cloudstream` that lives in the cloud and has specific subjects and a specific configuration (size, retention, ...).
2. `mystream` that lives on each edge runtime that is participating in the network. It has different subjects and a different stream configuration.
3. `mystream_aggregate` that lives on the cloud and collects/aggregates the data from the streams linked to that are running on the edge runtimes.

See the [edge-nats-box.yaml](edge-nats-box.yaml) for details.

# cloud-only.yaml

This example shows how to define a single application running on the cloud runtime only.

It runs a simple nginx webserver on the cloud runtime.
The specified edge-worker resource `cloud-application1` is labeled with `release: stable`.

See the [cloud-app.yaml](cloud-app.yaml) for details.

# edge-app.yaml

This example shows how to define a single application running on the edge runtime only.
It runs a simple Nginx web server only on edge runtimes that have both labels `mynode` and `cheesebread` set.
The specified edge-worker resource `edge-application1` is labeled with `app: edge-application1`.

See the [edge-app.yaml](edge-app.yaml) for details.