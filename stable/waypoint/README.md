# Hashicorp Waypoint Helm Chart created by Fuchicorp

## Prerequisites Details
* Kubernetes 
* PV support on underlying infrastructure
* Waypoint CLI v0.1.4+ [Click here to view Waypoint CLI installation documentation ](https://learn.hashicorp.com/tutorials/waypoint/get-started-install?in=waypoint/get-started-kubernetes)  
* TLS certificates or a way to provision them

## StatefulSet Details
* http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/

## Chart Details
This chart will do the following:

* Deploy the Hashicorp Waypoint server using Kubernetes StatefulSet and configure communication between the Waypoint Server and the Waypoint CLI.  

## Chart Installation
To get started add our repository 
```bash
$  helm repo add fuchicorp https://fuchicorp.github.io/helm_charts
```

## Install Waypoint chart 
This chart will install the Waypoint server as a Loadbalancer which is the default for the Waypoint install.  If you would like to use a ClusterIP or NodePort, please see below for further information on customizing this helm chart. 

To install the chart with the release name `waypoint`:

```
$ helm install --name waypoint fuchicorp/waypoint
```
## Install into a Namespace 
```
cd /helm_charts/stable/
$ helm install --name waypoint ./waypoint --namespace tools
```

## Upgrading chart, after changing values in values.yaml
```bash
$ helm upgrade waypoint ./waypoint
```
## Fetch the Waypoint chart and customize

```bash
$ helm fetch fuchicorp/waypoint --untar
```

## Installing the custom chart

To install the chart with the release name `waypoint`:

```bash
$ helm install --name waypoint fuchicorp/waypoint
```
## After Install Instructions
Once you have installed your chart you will see that we have populated the bootstrapping, context and verify commands for you. You can copy and paste these into your prompt to complete the process quickly. 

## Configurations of the Waypoint helm chart
 Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `Name`                  | Waypoint statefulset name               | `waypoint`                                                   |
| `Image`                 | Container image name                  | `hashicorp/waypoint`                                                   |
| `ImageTag`              | Container image tag                   | `0.1.5`                                                    |
| `ImagePullPolicy`       | Container pull policy                 | `IfNotPresent`                                                   |
| `securityContext`       | set fsGroup                           | `1000`                                                     |
| `nameOverride`                    | Override the resource name prefix    | `waypoint`                                 |
| `fullnameOverride`                | Override the full resource names     | `waypoint-{release-name}` (or `waypont` if release-name 
| `service.type`        | Configures the service type       | `LoadBalancer`, `ClusterIP` or `NodePort`                                               |
| `service.port`        | Configures the service port  | `80`                                                |
| `service.waypointGrpcPort`        | Configures the grpc service port  | `9701`                                                |
| `service.waypointServerPort`        | Configures the https service port  | `9702`                                                |
| `waypointGrpc.Ingress.enabled`     | Create Ingress for Waypoint CLI (grpc)      | `true`                                                    |
| `waypointGrpc.Ingress.annotations` | Associate annotations to the Ingress  | `{}`                                                       |
| `waypointGrpc.Ingress.labels`      | Associate labels to the Ingress       | `{}`                                                       |
| `waypointGrpc.Ingress.hosts`       | Associate hosts with the Ingress      | `[]`                                                       |
| `waypointGrpc.Ingress.path`        | Associate TLS with the Ingress        | `/`                                                        |
| `waypointGrpc.Ingress.tls`         | Associate path with the Ingress       | `[]`                                                       |
| `waypointServer.Ingress.enabled`     | Create Ingress for Waypoint UI (https)      | `true`                                                    |
| `waypointServer.Ingress.annotations` | Associate annotations to the Ingress  | `{}`                                                       |
| `waypointServer.Ingress.labels`      | Associate labels to the Ingress       | `{}`                                                       |
| `waypointServer.Ingress.hosts`       | Associate hosts with the Ingress      | `[]`                                                       |
| `waypointServer.Ingress.path`        | Associate TLS with the Ingress        | `/`                                                        |
| `waypointServer.Ingress.tls`         | Associate path with the Ingress       | `[]`                                                       |
| `Resources`             | Container resource requests and limits| `{}`                                                       |
| `nodeSelector`          | Node labels for pod assignment        | `{}`                                                       |
| `affinity`              | Affinity settings                    | `{}`                                               |
| `tolerations`           | Tolerations for pod assignment        | `[]`                                                       |

## Configuring Service 
Waypoint uses two different ports, gRPC is required but you can disable the web UI if you would like. Of course, you won't really need to use this chart if that is the case. <br>
- **HTTP API (Default 9702, TCP)** - This is used to serve the web UI and the web UI API client. If the web UI is not used, this port can be blocked or disabled. <br>
- **gRPC API (Default 9701, TCP)** - This is used for the gRPC API. This is consumed by the CLI, Entrypoint, and Runners. This port must be reachable by all deployments using the Entrypoint. <br> <br>
Both of these ports require TCP, but the connections are always TLS protected. Non-TLS connections are not allowed on either port. 
[Please click for further information on Waypoint Server in Production](https://www.waypointproject.io/docs/server/run/production) <br>

### **Examples below are of the service type and ports associated:**
  - **LoadBalancer** 
```
service:
  type: LoadBalancer
  waypointGrpcPort: 9701
  waypointServerPort: 9702
  ```
  - **ClusterIP** 
```
service:
  type: ClusterIP
  waypointGrpcPort: 443
  waypointServerPort: 80
```
  - **NodePort** 
```
service:
  type: NodePort
  waypointGrpcPort: 9701
  waypointServerPort: 9702
```
Please note, you will need to allow access for these ports via your firewall or security group.  We have provided the suggested commands for bootstrapping,context and verify but the NodPort is not fully tested. 

## Enable Ingresses (ClusterIP)
Important to note that currently Waypoint has a TLS limitation [click here to read more](https://www.waypointproject.io/docs/server/run/production). We have configured this chart with the suggested work around given by Waypoint. With the help of the ingress-controller (nginx in this case) both ingress annotations must be configured to terminate the TLS with your desired TLS certificate. The backend connection must use the self-signed TLS connection to the Waypoint server. This is accomplished by activating the following annotations for each ingress. 
### Annotations <br>   
  - **waypointGrpc annotations** <br>
```       
nginx.ingress.kubernetes.io/ssl-passthrough: "true" <br>
nginx.ingress.kubernetes.io/ssl-redirect: "true"   <br> 
nginx.ingress.kubernetes.io/backend-protocol: GRPCS <br>
```

   - **waypointServer annotations** <br>
```
 nginx.ingress.kubernetes.io/backend-protocol: HTTPS 
 nginx.ingress.kubernetes.io/proxy-http-version: "1.0"
```

- **nginx.ingress.kubernetes.io/ssl-passthrough** instructs the controller to send TLS connections directly to the backend instead of letting NGINX decrypt the communication.
- **nginx.ingress.kubernetes.io/ssl-redirect** will enforce a redirect to HTTPS even when there is no TLS certificate available.
- **nginx.ingress.kubernetes.io/backend-protocol** indicates how NGINX should communicate with the backend service. <br>
_Valid Values: HTTP, HTTPS, GRPC, GRPCS, AJP and FCGI._ <br>
- **nginx.ingress.kubernetes.io/proxy-http-version** Using this annotation sets the proxy_http_version that the Nginx reverse proxy will use to communicate with the backend. By default this is set to "1.1". <br>
[Here is a list of all possible nginx ingress-controller annotations.](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) <br>
If you are using a cert-manager to complete your TLS requests, please ensure to add that annotation for both ingresses.
### Hosts 
  - **waypointGrpc** <br>
Add your domain name for GRPC to use.  We suggest "waypoint-grpc.cluster.local".  This will help to define the difference between the grpc and https domains.
   - **waypointServer** <br>
       Add your domain name for HTTPS to use.  We suggest "waypoint.cluster.local". This address will bring you to the Waypoint UI login screen. 

### TLS
  - Both the waypointGrpc and waypointServer require tls certs. If you have a cert-manager completing these requests, please ensure to add that annotation for both ingress mentions. 

## Bootstrapping, Context and Verify
Once you have installed this chart you will see that we have populated the bootstrapping, context and verify commands for you. You can copy and paste these into your prompt to complete the process quickly. Below is further information about why we need to run these commands and where you can find other Waypoint options.<br>
### Bootstrapping
We will need to bootstrap the server to be able to receive the initial token. The waypoint token new command will not work until you have bootstrapped.
We will also specify the server address, the server-tls-skip-verify, and context name within this command.
-**server-tls** - If true, will connect to the server over TLS.
-**server-tls-skip-verify** - If true, will not validate TLS cert presented by the server.
-**context-create** - Create a CLI context for this bootstrapped server. The context name will be the value of this flag. If this is an empty string, a context will not be created
Both server-tls and server-tls-skip-verify are important because we are terminating the TLS cert the server generates automatically on start up and are providing our own.
```
waypoint server bootstrap -server-addr=waypoint-grpc.yourdomain.com:443 -server-tls-skip-verify -context-create="k8s-server"
```
[Click here to see more command options available.](https://www.waypointproject.io/commands/server-run)

[Click here to see more command options available for context.](https://www.waypointproject.io/commands/context-create)

### Verify
This is an easy one! You are just verifying that you can able to connect the CLI to the server with the context you setup. Please list the context name you create in the earlier step, as you can see, we used the "k8s-server".
```
 waypoint context verify k8s-server
```
### Waypoint Server Address
We also provide a copy of your url address of the Waypoint server. Copy and paste into your browser and you should see the welcome screen. To grab your token to authenticate, run the following command below. Copy and paste the token text into the UI and you should be able to login.
```
echo $WAYPOINT_INIT_TOKEN
```

## Hello-world App Testing
Now that you have your waypoint server up and running you can now test this tool with our hello-world application. We have created a simple docker build and kubernetes deployment of the hello world app utilizing the waypoint.hcl file. You can navigate in the Fuchicorp repository to [helm_charts/examples/waypoint/hello-world-demo](https://github.com/fuchicorp/helm_charts/tree/feature/%232/examples/waypoint/hello-world-demo).  We have a README file with detailed instructions on how to deploy along with other great information and resources links about the waypoint.hcl configuration options.


## Delete the Chart
```
$ helm delete --purge waypoint 
```
Storage pvc will not get deleted, to delete storage persistent volume claim, run:
```
$ kubectl delete pvc data-waypoint-0
```