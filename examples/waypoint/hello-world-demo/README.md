<img src="https://i.ibb.co/W3Rdchy/waypoint-logo.jpg" alt="waypoint-logo" border="0"><br>

## Prerequisites Details
* Kubernetes 
* Docker
* Waypoint CLI v0.1.4+ [Click here to view Waypoint CLI installation documentation ](https://learn.hashicorp.com/tutorials/waypoint/get-started-install?in=waypoint/get-started-kubernetes)  
* Waypoint Server v0.1.5+ [Click here to link to our Waypoint Server helm chart](https://github.com/fuchicorp/helm_charts/tree/feature/%232/stable/waypoint) 

## Project and App Stanzas:
- First changes we made were to name the project.  The project name can be whatever you would like to name it, it will show up as this name in your server ui. 

- Add an app name.  Much like the project this name can be whatever you would like to help identify what app you are deploying in this file. In this case we kept it simple and named the project and app the same name. 

- Add the path to the app waypoint would be building. In this case we have the Dockerfile and app.py located in the deployment/docker path which we specified. 

- We added labels for service and env.  We did this for testing purposes but when deployed we did see that these labels are not added to the pod, so I'm not sure the source case for this label definition. 

```
project = "hello-world"

app "hello-world" {
  path = "./deployments/docker"
  labels = {
      "service" = "hello-world"
      "env" = "dev"
  }
```
## Build Stanza:  

- Building your Dockerfile image and pushing it to our Dockerhub. Which is why the use is specified as "docker".  
- Next Add registry stanza and again specify that we are pushing this image with "docker".  
- In this registry docker stanza we input our image name which is your docker_username/docker_image_name. Then we can add the tag for the version if we would like.  If you do not add this by default it will be named "latest".   

- Now add your credentials for dockerhub to be able to push the image.  To accomplish this by making a simple auth json file with that information.  Its very easy to configure, I have an example below. If you are using this sample name is dockerAuth.json to make is simple. <br>
*Note: do not have spaces
```
{"username":"xxx","password":"xxx","email":"xxx"}
```
- Now add encoded_auth = filebase64("path/to/json/file"), it will pull those credentials to take with dockerhub to push. 

```
 build {
    use "docker" {
    }
    registry {
        use "docker" {
          image = "docker_username/docker_image_name"
          tag = "v1"
          encoded_auth = filebase64("./deployments/docker/dockerAuth.json")
        }
    }
 }
```
- You can test this stanza only by running the `waypoint build` command.  This helps to troubleshoot the sections of our code. You do need to run the waypoint init first before the build command. 
```
waypoint init
waypoint build
```
## Deploy Stanza:
- Set use as "kubernetes" because this is the platform we will be using to deploy the docker image to.
- Add the service_port of the Dockerfile app which for Flask is port 5000.  
- Define the namespace you wish to deploy to. In this example we will use "tools" to deploy the pod to.  If you remove namespace completely it will deploy automatically to your default namespace. 
```
   deploy {
     use "kubernetes" {
       service_port = 5000 
       namespace = "tools"
       annotations = {"kubernetes.io/ingress.class":"nginx","cert-manager.io/cluster-issuer":"letsencrypt-prod"}
    }
  }
```
## Release Stanza
- Set use as "kubernetes" and use the LoadBalancer and indicate the port 5000 to be exposed. This way it will expose the service for you to view.  

## Full code for waypoint.hcl example
```
project = "hello-world"

app "hello-world" {
  path = "./deployments/docker"
  labels = {
      "service" = "hello-world"
      "env" = "dev"
  }

  build {
    use "docker" {
    }
    registry {
        use "docker" {
          image = "docker/image"
          tag = "v1"
          encoded_auth = filebase64("./deployments/docker/dockerAuth.json")
        }
    }
 }

   deploy {
     use "kubernetes" {
       namespace = "tools"
       service_port = 5000 
       annotations = {"kubernetes.io/ingress.class":"nginx","cert-manager.io/cluster-issuer":"letsencrypt-prod"}
    }
  }

   release {
      use "kubernetes" {
        namespace = "tools"
        LoadBalancer = True
        port = 5000
     }
   }
  
}

```

## Let's deploy this hello-world example
- Save your full code and in the folder where your waypoint.hcl is located we will run the waypoint up command.  This command will run each stanza sequentially in the code to build, deploy and release your code.   
```
waypoint init
waypoint up
```
<br>
<img src="https://i.ibb.co/42ytcxW/waypoint-up.jpg" alt="waypoint-up" border="0"> 
<br>

## Videos
- Official Hashicorp Waypoint Intro and Demo [Click here to view](https://www.youtube.com/watch?v=nasVKN7Wbtk) <br>

- Hashicorp Waypoint Deep-Dive [Click here to view](https://www.youtube.com/watch?v=0Q0VE5oPL8Y&t=671s) <br>

- Introduction to Hashicorp Wapoint with Armon Dadgar [Click here to view](https://www.youtube.com/watch?v=JL0Qeq4A6So) <br>
This goes more into the thinking behind Waypoint much more and I highly recommend. 

## Documentation
- Waypoint Official Documentation [Click here to view](https://www.waypointproject.io/docs)
- Waypoint Hashicorp Learn Tutorials [Click here to view](https://learn.hashicorp.com/waypoint)
- Waypoint Hashicorp Example Repo [Click here to view](https://github.com/hashicorp/waypoint-examples.git)
