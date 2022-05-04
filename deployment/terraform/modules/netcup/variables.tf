variable "server_ip" {
  type = string
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

variable "domain" {
  type = string
}

variable "subdoamin" {
  type = list(string)
}
