# mixed-app examples

# mixed-app-network

This example shows how to define a mixed application running on both edge and cloud runtimes.
It runs one Nginx web server on the cloud runtime and two instances of the same Nginx web server on all edge runtimes. 
Due to the missing `runtime` field the edge applications are scheduled on each edge runtime.
The specified main-worker resource `cloud-application1` is labeled with `app: cloud-application1`.
The specified edge-worker resource `edge-application1` is labeled with `app: edge-application1`.
The specified edge-worker resource `edge-application2` is labeled with `app: edge-application2`.

This example introduces the `application-network` component which allows to configure the EdgeFarm network for the application. 
The trait `network-participant` defines which component can communicate through the network. 

See the [mixed-app-network.yaml](mixed-app-network.yaml) for details.