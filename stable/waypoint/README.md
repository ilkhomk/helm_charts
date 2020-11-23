# Hashicorp Waypoint Helm Chart created by Fuchicorp

## Prerequisites Details
* Kubernetes 
* PV support on underlying infrastructure
* Waypoint CLI v0.1.4+ [Click here to view Waypoint CLI installation documentation ](https://learn.hashicorp.com/tutorials/waypoint/get-started-install?in=waypoint/get-started-kubernetes)  

## StatefulSet Details
* http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/

## Chart Details
This chart will do the following:

* Deploy the Hashicorp Waypoint server using Kubernetes StatefulSet and configure communication between the Waypoint Server and the Waypoint CLI.  

## Chart Installation
To get started add our repository 
```bash
$  helm repo add fuchicorp https://fuchicorp.github.io/helm_charts
$  helm update
```

## Install Waypoint chart directly with no custom configurations
This chart will install the Waypoint server with a Loadbalancer which is the default for the Waypoint install.  If you would like to use a ClusterIP or NodePort, please see below for further information on customizing this helm chart. 

To install the chart with the release name `waypoint`:

```
$ helm install --name waypoint fuchicorp/waypoint
```
## Install into a Namespace 
```
cd /helm_charts/stable/
$ helm install --name waypoint ./waypoint --namespace tools
```

## Without installing
```bash
$ helm install --name waypoint --debug --dry-run ./waypoint
```

## Upgrading chart, after changing values in values.yaml
```bash
$ helm upgrade waypoint ./waypoint
```
## Fetch the Waypoint chart and customize

```bash
$ helm fetch fuchicorp/waypoint --untar
```

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
  port: 80
```

## Enable Ingresses (ClusterIP)
Important to note that currently Waypoint has a TLS limitation [click here to read more](https://www.waypointproject.io/docs/server/run/production). We have configured this chart with the suggested work around given by Waypoint. With the help of the ingress-controller (nginx in this case) both ingress annotations must be configured to terminate the TLS with your desired TLS certificate. The backend connection must use the self-signed TLS connection to the Waypoint server. This is accomplished by activating the following annotations for each ingress. 
### Annotations <br>   
  - **waypointGrpc annotations** <br>
       nginx.ingress.kubernetes.io/ssl-passthrough: "true" <br>
       nginx.ingress.kubernetes.io/ssl-redirect: "true"   <br> 
       nginx.ingress.kubernetes.io/backend-protocol: GRPCS <br>

   - **waypointServer annotations** <br>
       nginx.ingress.kubernetes.io/backend-protocol: HTTPS 

### Hosts 
  - **waypointGrpc** <br>
Add your domain name for GRPC to use.  We suggest "waypoint-grpc.cluster.local".  This will help to define the difference between the grpc and https domains.
   - **waypointServer** <br>
       Add your domain name for HTTPS to use.  We suggest "waypoint.cluster.local". This address will bring you to the Waypoint UI login screen. 

### TLS
  - Both the waypointGrpc and waypointServer require tls certs. If you have a cert-manager completing these requests, please ensure to add that annotation for both ingress mentions. 

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

## Installing the custom chart

To install the chart with the release name `waypoint`:

```bash
$ helm install --name waypoint fuchicorp/waypoint
```
- Please follow the further command instructions given after the helm chart has been successfully deployed.  These steps help to bootstrap the server, retrieve your token and create the context communication between the cli and server. Once all commands have been completed the server will be ready to work with the cli and pull all your important build, deployment and release information.  

## Delete the Chart
```
$ helm delete --purge waypoint 
```