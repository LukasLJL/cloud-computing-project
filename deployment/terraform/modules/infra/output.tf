output "master_ip" {
    value = openstack_compute_instance_v2.worker["srv-01"].access_ip_v4
}

