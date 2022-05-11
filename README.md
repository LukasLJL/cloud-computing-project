# Cloud-Computing Project
This is a Project for the DHBW Course Cloud-Computing.
The Project contains a basic Hugo Website with a CI/CD Pipeline and a Terraform script to build a complete k3s Cluster with any Openstack Provider.

## Hugo
This Website uses the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) Theme.

### Usage
To start the Website locally run ``hugo server -D`` <br>
If you want to create new post run ``hugo new --kind post posts/my_new_post.md``

### Deployment
This Website is deployed at a self-hosted Kubernetes Cluster. 
If you want to checkout the deployment files go to ``./deployment/kubernetes``. The ``deployment.yaml`` contains
the actual deployment, service and ingressroute for Traefik.

### CI/CD
The live website hosted at [hugo.lukasljl.de](https://hugo.lukasljl.de) is updated after a push to the master branch. The CI/CD Pipeline will build a Docker-Image and update the current Kubernetes Deployment Image-Tag to force an restart of all running pods.

## K3S Cluster
There is specific README for the K3S Cluster: [README.md](./deployment/README.md)