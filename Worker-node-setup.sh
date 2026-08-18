#!/bin/bash

# Exit Immediately on Error
set -e

echo "===== Kubernetes WORKER Setup (Auto) ====="

# Generate unique hostname based on IP
IP=$(hostname -I | awk '{print $1}')
HOSTNAME="worker-$(echo $IP | tr '.' '-')"

# Set Hostname. Why? Kubernetes nodes need unique names. Without a proper hostname: ip-172-31-1-10 appears in cluster output. Using: master makes administration easier.
echo "Setting hostname to $HOSTNAME"
sudo hostnamectl set-hostname $HOSTNAME

# Disable swap
# Why? Kubernetes requires swap to be disabled. Historically kubelet refuses to start if swap is enabled. Reason: Kubernetes scheduler assumes memory accounting is accurate.
# Swap makes memory usage unpredictable.

sudo swapoff -a

# Disable Swap Permanently
# After reboot: swapoff -a is forgotten.
# Linux reads: /etc/fstab and re-enables swap.
# sed = Stream editor. -i means Edit file in place.
# Find lines containing:  swap
# Substitute: start of line (^)
# with #
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Create Kernel Module Configuration because Kubernetes networking requires Linux kernel modules.
# overlay: Used by container filesystem layers.
# br_netfilter: Allows iptables to inspect bridge traffic.
# Needed by: Kubernetes Services, kube-proxy, Calico
# Loaded automatically during boot.
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Load Modules Immediately
# modprobe: Loads Linux kernel module dynamically.
sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl settings. Configure Kernel Networking
# Kubernetes pods communicate across nodes. Linux must allow packet forwarding.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf

# Bridge traffic passes through iptables. Needed by: Calico, kube-proxy
net.bridge.bridge-nf-call-iptables = 1

# Linux can route packets. Without it: Pod A → Pod B fails.
net.ipv4.ip_forward = 1
EOF

# Apply Sysctl Settings. Reads all files under: /etc/sysctl.d/ and applies settings immediately.
sudo sysctl --system

# Install containerd
sudo apt update

# Install Container Runtime, Downloads latest package metadata.
# containerd: Container runtime. Actually runs containers.
# apt-transport-https: Allows APT repositories over HTTPS. Historically required; newer Ubuntu versions include HTTPS support by default but many guides still install it.
# ca-certificates: Trusted SSL certificates. Needed for secure downloads.
# curl: Downloads files via HTTP/HTTPS. Used later for Kubernetes repository key.
sudo apt install -y containerd apt-transport-https ca-certificates curl

# Create containerd Configuration. Create parent directories if missing.
sudo mkdir -p /etc/containerd

# Generates default configuration.
containerd config default | sudo tee /etc/containerd/config.toml

# Enable systemd cgroup
# Modern Kubernetes recommends: systemd cgroup driver
# for kubelet and containerd. Both must use same cgroup driver. Otherwise errors such as: cgroup driver mismatch occur.
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Start Containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
# Kubernetes packages are not maintained in Ubuntu default repositories.
# Create key directory
sudo mkdir -p /etc/apt/keyrings

# Download signing key
# | Flag | Meaning             |
# | ---- | ------------------- |
# | -f   | Fail on HTTP errors |
# | -s   | Silent              |
# | -S   | Show errors         |
# | -L   | Follow redirects    |

# Store key:sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes tools
sudo apt update

# kubelet: Node agent. Runs on every node.
# kubeadm: Cluster bootstrap utility. Creates cluster.
# kubectl: CLI tool. Used by administrators.
sudo apt install -y kubelet kubeadm

# Prevent Automatic Upgrades. Automatic upgrades can create version mismatch.
sudo apt-mark hold kubelet kubeadm

echo ""
echo "===== WORKER SETUP COMPLETE ====="
echo "Hostname: $HOSTNAME"
echo ""
echo "👉 NEXT STEP:"
echo "Run the join command from MASTER like below:"
echo ""
echo "sudo kubeadm join <MASTER-IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH> --v=5"
echo ""
echo "After joining, verify on MASTER:"
echo "kubectl get nodes"
