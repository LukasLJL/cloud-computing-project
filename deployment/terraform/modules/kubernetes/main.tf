resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  values = [
    "${file("deployments/traefik/values.yaml")}"
  ]

  set {
    name  = "service.spec.loadBalancerIP"
    value = var.loadBalancerIP
    type  = "string"
  }
}
