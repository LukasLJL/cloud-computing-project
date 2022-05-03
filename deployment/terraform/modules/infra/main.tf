/*
* Module for Basic Infrastucture like SSH-Keys, Intances, Volumes etc.
*/

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
      description = "Worker Node"
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


#SSH-Key
resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = "ssh-key-cc"
  public_key = var.public_key
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
  security_groups = ["default", openstack_compute_secgroup_v2.k3s.id, openstack_compute_secgroup_v2.web.id]

  metadata = {
    desc = each.value.description
  }

  network {
    name = "public-belwue"
  }
}

# Execute SSH Commands on the new Server
resource "null_resource" "init-setup" {
  for_each = openstack_compute_instance_v2.worker
  connection {
    type        = "ssh"
    host        = each.value.access_ip_v4
    user        = "ubuntu"
    port        = 22
    private_key = var.private_key
  }

  # Update Ubuntu-Server and install Basic Packages
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y htop neofetch vim tmux nload",
    ]
  }
}