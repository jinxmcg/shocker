# ⚡ Shocker

> Ultra-fast autoscaler that launches pre-snapshotted Firecracker microVMs as Kubernetes nodes using Flintlock.

---

## 🚀 Overview

**Shocker** is a Kubernetes-native autoscaler that adds nodes in **~1 second** by restoring Firecracker microVMs from snapshots using **Flintlock**.

Unlike traditional autoscalers that provision full VMs or containers, Shocker spins up ultra-lightweight Firecracker VMs that:
- Are pre-joined to Kubernetes
- Use Cilium for pod networking
- Boot instantly from memory+disk snapshots
- Have unique MAC/IP and node names per launch

---

## 🧱 Architecture

### Components

- **Flintlock** – microVM manager that launches Firecracker VMs via CRD or REST API
- **Prebuilt Snapshots** – VMs with k3s/kubelet pre-installed and running at snapshot time
- **Shocker Controller** – launches new VMs by POSTing to Flintlock API
- **Cilium** – handles pod networking with support for dynamic VM tap devices

### Flow

1. Basic k3s cluster running
2. Shocker controller:
    - Picks an unused IP/MAC
    - Builds a MicroVM YAML (or JSON) spec
    - Calls Flintlock API to restore a snapshot
3. Firecracker restores the VM
4. VM auto-registers with Kubernetes in ~1s using:
    - Preconfigured `k3s agent` already running
    - Node identity injected at boot

---

## 🔧 Requirements

- Flintlock and Firecracker installed on node hosts
- A snapshot of a "golden" k3s node (already joined)
- Bridge interface for tap networking (e.g. `br0`)
- Cilium with native routing or BGP
- Kubernetes cluster (any control plane)

---

## 🧪 Snapshot Creation Plan

1. Start a microVM manually via Flintlock
2. Inside the VM:
    - Install `k3s` and join the cluster
    - Configure static IP networking
3. Clean up identity-sensitive files:
    ```bash
    rm -rf /var/lib/kubelet/pki/*
    rm -rf /etc/rancher/k3s/k3s.yaml
    ```
4. Shut down the VM and take a snapshot using Firecracker or Flintlock

---

## 🔁 Autoscaling Logic

- Input: Pod pending queue, CPU usage, or Prometheus metric
- Decision: Launch X new nodes if metric threshold is hit
- Action: For each node:
    - Generate MAC, IP, and node name
    - Launch via Flintlock
    - Wait for K8s `Ready` state (optional)

---

## 🛣️ Roadmap

- [ ] Working minimal controller with Flintlock POST
- [ ] IP/MAC allocator module
- [ ] Cilium ClusterMesh compatibility
- [ ] Optional custom CRD for scale policies
- [ ] Cleanup logic for idle VMs

---

## 🧠 Inspiration

- Firecracker's snapshot-based restore time
- k3s + Cilium + snapshot = nearly instant node
- Event-driven node auto-scaling with <2s latency

