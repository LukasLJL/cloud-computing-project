terraform {
  required_version = ">= 1.1.7"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

variable "instances" {
  type = map(any)
  default = {
    srv-01 = {
      name        = "cc-srv-01"
      description = "Master Node"
      type        = "m1.medium"
    }
    srv-02 = {
      name        = "cc-srv-02"
      description = "Worker Node"
      type        = "m1.small"
    }
    srv-03 = {
      name        = "cc-srv-03"
      description = "Worker Node"
      type        = "m1.small"
    }
  }
}

# Geneate K3S Token
resource "random_password" "k3s_token" {
  length  = 24
  special = false
}


#SSH-Key
resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = "ssh-key-cc"
  public_key = file(var.public_key_path)
}

#Port Config for HTTP/S
resource "openstack_compute_secgroup_v2" "web" {
  name        = "http"
  description = "default http/s ports"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

#Port Config for Kubernetes Management API
resource "openstack_compute_secgroup_v2" "k3s" {
  name        = "kubernetes"
  description = "kubernetes management ports for example cli access"
  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

#Create Master-Node and two Worker-Nodes
resource "openstack_compute_instance_v2" "worker" {
  for_each        = var.instances
  name            = each.value.name
  image_id        = "2e170e26-3749-4326-b716-437379c9ba93"
  flavor_name     = each.value.type
  key_pair        = openstack_compute_keypair_v2.ssh_key.name
  security_groups = ["default", openstack_compute_secgroup_v2.k3s.name, openstack_compute_secgroup_v2.web.name]
  user_data       = file("init_script.sh")

  metadata = {
    desc = each.value.description
  }

  network {
    name = "public-belwue"
  }
}

# Install K3S on master-node
resource "null_resource" "k3s-master-setup" {
  connection {
    type        = "ssh"
    host        = openstack_compute_instance_v2.worker["srv-01"].access_ip_v4
    user        = "ubuntu"
    port        = 22
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - --disable=traefik && sudo chmod 644 /etc/rancher/k3s/k3s.yaml"
    ]
  }
}

# Install K3S on worker-nodes and join cluster
resource "null_resource" "k3s-node-setup" {
  depends_on = [null_resource.k3s-master-setup]
  for_each = {
    for key, value in openstack_compute_instance_v2.worker : key => value
    if key != "srv-01"
  }

  connection {
    type        = "ssh"
    host        = each.value.access_ip_v4
    user        = "ubuntu"
    port        = 22
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${openstack_compute_instance_v2.worker["srv-01"].access_ip_v4}:6443 K3S_TOKEN=${random_password.k3s_token.result} sh -"
    ]
  }
}

# Copy kubeconfig from master-node to local-machine
resource "null_resource" "k3s-copy-config" {
  depends_on = [null_resource.k3s-master-setup]
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_path} ubuntu@${openstack_compute_instance_v2.worker["srv-01"].access_ip_v4}:/etc/rancher/k3s/k3s.yaml kube-config.yaml"
  }
  provisioner "local-exec" {
    command = "sed -i 's/127.0.0.1/${openstack_compute_instance_v2.worker["srv-01"].access_ip_v4}/g' kube-config.yaml"
  }
}

