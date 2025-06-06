terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "cluster-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_network" "cluster_network" {
  name     = "cluster-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "cluster_subnet" {
  network_id   = hcloud_network.cluster_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "cluster_firewall" {
  name = "cluster-firewall"

  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = ["0.0.0.0/0"]
  }

  rule {
    direction = "in"
    port      = "6443"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }

  rule {
    direction = "in"
    port      = "9090"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }

  rule {
    direction = "in"
    port      = "4789"
    protocol  = "udp"
    source_ips = ["10.0.0.0/16"]
  }

  rule {
    direction = "in"
    port      = "51820"
    protocol  = "udp"
    source_ips = ["10.0.0.0/16"]
  }
}

resource "hcloud_server" "control_plane" {
  count       = var.control_plane_count
  name        = "control-plane-${count.index + 1}"
  image       = var.custom_snapshot_id
  server_type = var.control_plane_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.cluster_firewall.id]

  network {
    network_id = hcloud_network.cluster_network.id
    ip         = "10.0.1.${count.index + 10}"
  }

  labels = {
    role = "control-plane"
  }

  depends_on = [
    hcloud_network_subnet.cluster_subnet
  ]
}

resource "hcloud_server" "worker_nodes" {
  count       = var.worker_node_count
  name        = "worker-${count.index + 1}"
  image       = var.custom_snapshot_id
  server_type = var.worker_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.cluster_firewall.id]

  network {
    network_id = hcloud_network.cluster_network.id
    ip         = "10.0.1.${count.index + 20}"
  }

  labels = {
    role = "worker"
  }

  depends_on = [
    hcloud_network_subnet.cluster_subnet
  ]
}

resource "hcloud_load_balancer" "k8s_api" {
  name               = "k8s-api-lb"
  load_balancer_type = "lb11"
  location           = var.location

  labels = {
    purpose = "kubernetes-api"
  }
}

resource "hcloud_load_balancer_network" "k8s_api" {
  load_balancer_id = hcloud_load_balancer.k8s_api.id
  network_id       = hcloud_network.cluster_network.id
  ip               = "10.0.1.5"
}

resource "hcloud_load_balancer_target" "k8s_api" {
  count            = var.control_plane_count
  type             = "server"
  load_balancer_id = hcloud_load_balancer.k8s_api.id
  server_id        = hcloud_server.control_plane[count.index].id
}

resource "hcloud_load_balancer_service" "k8s_api" {
  load_balancer_id = hcloud_load_balancer.k8s_api.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
  
  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}