# Hashicorp Waypoint Helm Chart created by Fuchicorp

## Prerequisites Details
* Kubernetes 
* PV support on underlying infrastructure
* Waypoint CLI v0.1.4+  [Click here to view Waypoint CLI installation documentation ](https://learn.hashicorp.com/tutorials/waypoint/get-started-install?in=waypoint/get-started-kubernetes)  

## StatefulSet Details
* http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/

## Chart Details
This chart will do the following:

* Deploy the Hashicorp Waypoint server using Kubernetes StatefulSet, a service, PVC and two ingresses that will configure communication between the Waypoint Server and the Waypoint CLI.  

## Add the Fuchicorp repo
```
$ 
```

## Installing the Chart

To install the chart with the release name `waypoint`:

```bash
$ helm install --name waypoint fuchicorp/waypoint
```
or
```
$ helm install waypoint fuchicorp/waypoint --set global.name=waypoint ??
```
- Please follow the further command instructions given after the helm chart has been successfully deployed.  These steps help to bootstrap the server, retrieve your token and create the context communication between the cli and server. Once all commands have been completed the server will be ready to work with the cli and pull all your important build, deloyment and release information.  

## Fetch the Chart
```
$ helm fetch --untar fuchicorp/waypoint
```
## Configurations of the Waypoint helm chart
### - Annotations <br>
Important to note that currently Waypoint has a TLS limitation [click here to read more](https://www.waypointproject.io/docs/server/run/production). We have configured this chart with the suggested work around suggest by Waypoint. With the help of the ingress-controller (nginx in this case) both ingress annotations must be configured to terminate the TLS with your desired TLS certificate. The backend connection must use the self-signed TLS connection to the Waypoint server. This is accomplished by activating the following annotations for each ingress. 
   - **GRPC** <br>
       nginx.ingress.kubernetes.io/ssl-passthrough: "true"
       nginx.ingress.kubernetes.io/ssl-redirect: "true"    
       nginx.ingress.kubernetes.io/backend-protocol: GRPCS <br>
   - **HTTPS** <br>
       nginx.ingress.kubernetes.io/ssl-passthrough: "true"
       nginx.ingress.kubernetes.io/ssl-redirect: "true"  
       nginx.ingress.kubernetes.io/backend-protocol: HTTPS

### - Hosts 
  - **GRPC** <br>
Add your domain name for GRPC to use.  We suggest waypoint-grpc-yourdomain.com.  This will help to define the difference between the grpc and https domains.
   - **HTTPS** <br>
       Add your domain name for HTTPS to use.  We suggest "waypoint-yourdomain.com". This address will bring you to the Waypoint UI login screen. 

### - TLS
  - Both the GRPC and HTTPS require tls certs. If you have a cert-manager completing these requests, please ensure to add that annotation for both ingress mentions. 

## Ports used by Waypoint
Waypoint requires two different ports:

- HTTP API (Default 9702, TCP) - This is used to serve the web UI and the web UI API client. If the web UI is not used, this port can be blocked or disabled.

- gRPC API (Default 9701, TCP) - This is used for the gRPC API. This is consumed by the CLI, Entrypoint, and Runners. This port must be reachable by all deployments using the Entrypoint.

Both of these ports require TCP, but the connections are always TLS protected. Non-TLS connections are not allowed on either port. Please click here to link to further information on these ports [Waypoint Server in Production](https://www.waypointproject.io/docs/server/run/production)

## What is GRPC 
gRPC is a remote procedure call protocol, used for communication between client and server applications. It is designed to be compact (space‑efficient) and portable across multiple languages, and it supports both request‑response and streaming interactions. The protocol is gaining popularity, including in service mesh implementations, because of its widespread language support and simple user‑facing design is currently utilized for the Hashicorp Waypoint tool.  
[Please click here for more detail information on gRPC](https://www.nginx.com/blog/nginx-1-13-10-grpc/)

## Hello-world App Testing
Now that you have your waypoint server up and running you can now test this tool with our hello-world application. We have created a simple docker build and kubernetes deployment of the hello world app utilizing the waypoint.hcl file. You can navigate here and clone this repository.  We also have a wiki and README with detailed instructions on how to deploy along with other great information and resources links about the waypoint.hcl configuration options.

## Delete the Chart
```
$ helm delete --purge waypoint 
```
