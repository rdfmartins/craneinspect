#!/bin/bash
echo "🚀 Iniciando Bootstrapping da Instância CraneInspect (FinOps MVP)"

# Atualizar pacotes do SO
apt-get update -y
apt-get upgrade -y

# Instalar AWS SSM Agent (Gerenciamento de Instância) e utilitários
apt-get install -y ca-certificates curl gnupg lsb-release amazon-ssm-agent unzip
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Instalar Docker & Docker-Compose (Protocolo FinOps - ADR-003)
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar o Docker
systemctl enable docker
systemctl start docker

# Preparar o usuário
usermod -aG docker ubuntu

# Instalar AWS CLI v2 para facilitar downloads de buckets
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "✅ Bootstrapping concluído com sucesso."
