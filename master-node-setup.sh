# Execute this file using the Bash interpreter.
#!/bin/bash

# Exit Immediately on Error
set -e

echo "===== Kubernetes MASTER Setup (Clean - t3.small) ====="

# Set hostname. Kubernetes nodes need unique names. Without a proper hostname:ip-172-31-1-10 appears in cluster output. Using:master makes administration easier.
sudo hostnamectl set-hostname master

# Disable swap
# Why? Kubernetes requires swap to be disabled. Historically kubelet refuses to start if swap is enabled. 
# Reason: Kubernetes scheduler assumes memory accounting is accurate. Swap makes memory usage unpredictable.

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
sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl settings
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Install containerd
sudo apt update
sudo apt install -y containerd apt-transport-https ca-certificates curl

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable systemd cgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes tools
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo ""
echo "===== MASTER SETUP COMPLETE ====="
echo "Run the below command on worker nodes:"
kubeadm token create --print-join-command
