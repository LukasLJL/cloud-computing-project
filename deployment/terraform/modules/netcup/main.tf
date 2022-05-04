terraform {
  required_providers {
    netcup-ccp = {
      source = "rincedd/netcup-ccp"
    }
  }
}

provider "netcup-ccp" {
  customer_number  = var.ccp_number
  ccp_api_key      = var.ccp_api_key
  ccp_api_password = var.ccp_api_password
}

resource "netcup-ccp_dns_record" "server_record" {
  for_each = toset(var.subdoamin)

  domain_name = var.domain
  name        = each.value
  type        = "A"
  value       = var.server_ip
}
