terraform {
  required_version = ">= 1.1.7"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

/*
* Provider Configuration
*/

# Auth Config OpenStack
provider "openstack" {
  cloud = "openstack"
}

module "infra" {
  source      = "./modules/infra"
  public_key  = file("~/.ssh/id_rsa.pub")
  private_key = file("~/.ssh/id_rsa")
}

