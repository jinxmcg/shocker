output "control_plane_public_ips" {
  description = "Public IP addresses of control plane nodes"
  value       = hcloud_server.control_plane[*].ipv4_address
}

output "worker_public_ips" {
  description = "Public IP addresses of worker nodes"
  value       = hcloud_server.worker_nodes[*].ipv4_address
}

output "control_plane_private_ips" {
  description = "Private IP addresses of control plane nodes"
  value       = hcloud_server.control_plane[*].network[0].ip
}

output "worker_private_ips" {
  description = "Private IP addresses of worker nodes"
  value       = hcloud_server.worker_nodes[*].network[0].ip
}

output "load_balancer_ip" {
  description = "Public IP of the Kubernetes API load balancer"
  value       = hcloud_load_balancer.k8s_api.ipv4
}

output "load_balancer_internal_ip" {
  description = "Internal IP of the load balancer"
  value       = hcloud_load_balancer_network.k8s_api.ip
}

output "network_id" {
  description = "ID of the cluster network"
  value       = hcloud_network.cluster_network.id
}