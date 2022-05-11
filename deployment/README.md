# Cloud-Computing Deployment

## Hugo Kubernetes Deployment
To deploy this website you can use any Kubernetes System which you have access to.
- First Create a new namespace for this project ``kubectl ns create cloud-computing``
- Apply the deployment file ``kubectl apply -f deployment.yaml``

Now the deployment for this website should be running. Keep in mind currently the Ingress is set to ``hugo.lukasljl.de`` you might have to change this.

## K3S Cluster Terraform Deployment
If you want to create a fresh k3s cluster you will need access to an Openstack Instance and a valid credentials file at ``~/.config/openstack``.
My Domain is managed by netcup, so this Terraform is optimized for netcup. If you have a different domain provider you have to change the Domain handling.
To provide api access to my netcup domain for example you will have to set some environment variables, as shown in the following:
````bash
export TF_VAR_ccp_number=your_ccp_number 
export TF_VAR_ccp_api_key=your_api_key 
export TF_VAR_ccp_api_password=your_api_password
````
The Default Configuration uses your ssh-key located at ``~/.ssh/id_rsa`` if you want to use a different ssh-key change this in the ``main.tf``

Now you should be able to just use terraform, here is quick setup guide
- ``terraform init`` - to download all necessary provider files.
- ``terraform apply`` - creates the k3s cluster with 3 instances.
- ``terraform destroy`` - deletes the k3s cluster and all instances.

The Terraform script creates 3 instances one for the master-node and 2 for regular-nodes. The Master-Node has more Ressource because it has to manage the k3s cluster.

## Adding Kubernetes Config File
To add the Kubernetes Config file to a github secret run ``cat ./terraform/kube-config.yaml | base64``

## Managing Kubernetes & Add whoami deployment
You have to add the ``./terraform/kube-config.yaml`` to your default kubeconfig or use something like this ``export KUBECONFIG=~/.kube/kube-config.yaml``
After that you can run ``kubectl apply -f ./deployments/whoami.yaml``, you may have to change the url in this file.
