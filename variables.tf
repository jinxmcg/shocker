variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "custom_snapshot_id" {
  description = "ID of the custom snapshot with patched kernel and Firecracker"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "control_plane_server_type" {
  description = "Server type for control plane nodes"
  type        = string
  default     = "cx31"
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx31"
}

variable "location" {
  description = "Hetzner Cloud location/datacenter"
  type        = string
  default     = "nbg1"
}