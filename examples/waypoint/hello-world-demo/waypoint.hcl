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
