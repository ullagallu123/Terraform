#!/bin/bash

set -euo pipefail

# Define versions
CONTAINERD_VERSION="2.0.0"
RUNC_VERSION="1.2.1"
CNI_VERSION="1.6.0"
K8S_VERSION="1.31"

# Enable IP Forwarding
echo "Configuring sysctl for IP forwarding..."
SYSCTL_CONF="/etc/sysctl.d/k8s.conf"
if ! grep -q "net.ipv4.ip_forward = 1" "$SYSCTL_CONF" 2>/dev/null; then
  echo "net.ipv4.ip_forward = 1" | sudo tee "$SYSCTL_CONF"
  sudo sysctl --system
fi

# Install containerd
echo "Installing containerd..."
if ! command -v containerd &>/dev/null; then
  wget -q "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
  tar xvf "containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
  sudo mv bin/* /usr/local/bin/
fi

# Install runc
echo "Installing runc..."
if ! command -v runc &>/dev/null; then
  wget -q "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64"
  sudo install -m 755 runc.amd64 /usr/local/sbin/runc
fi

# Install CNI plugins
echo "Installing CNI plugins..."
if [ ! -d "/opt/cni/bin" ]; then
  mkdir -p /opt/cni/bin
  wget -q "https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
  tar Cxzvf /opt/cni/bin "cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
fi

# Configure containerd
echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
if [ ! -f "/etc/containerd/config.toml" ]; then
  containerd config default | sudo tee /etc/containerd/config.toml
fi
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Set up containerd service
if [ ! -f "/etc/systemd/system/containerd.service" ]; then
  sudo curl -L "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" -o /etc/systemd/system/containerd.service
fi
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install Kubernetes components
echo "Installing Kubernetes components..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

if [ ! -f "/etc/apt/keyrings/kubernetes-apt-keyring.gpg" ]; then
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

if [ ! -f "/etc/apt/sources.list.d/kubernetes.list" ]; then
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
fi

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "Kubernetes and dependencies installation completed successfully!"
