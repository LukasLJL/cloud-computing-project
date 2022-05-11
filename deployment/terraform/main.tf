terraform {
  required_version = ">= 1.1.7"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
  }
}

/*
* Provider Configuration
*/
provider "openstack" {
  cloud = "openstack"
}

provider "kubernetes" {
  config_path    = "kube-config.yaml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path = "kube-config.yaml"
  }
}

variable "ccp_number" {
  type = number
}

variable "ccp_api_key" {
  type = string
}

variable "ccp_api_password" {
  type = string
}

module "infra" {
  source      = "./modules/infra"
  private_key_path = "~/.ssh/id_rsa"
  public_key_path = "~/.ssh/id_rsa.pub"
}

module "netcup" {  
  source           = "./modules/netcup"
  ccp_number        = var.ccp_number
  ccp_api_key       = var.ccp_api_key
  ccp_api_password  = var.ccp_api_password
  domain           = "lukasljl.de"
  subdoamin        = ["*.hugo", "hugo"]
  server_ip        = module.infra.master_ip
}

module "kubernetes" {
  depends_on     = [module.infra]
  source         = "./modules/kubernetes"
  loadBalancerIP = module.infra.master_ip
}

