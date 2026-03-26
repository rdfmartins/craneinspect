#!/bin/bash
echo "🚀 Iniciando Bootstrapping da Instância CraneInspect (FinOps MVP)"

# Assegurar instalações desassistidas
export DEBIAN_FRONTEND=noninteractive

# Atualizações do SO
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release unzip

# Instalar AWS SSM Agent (Gerenciamento de Instância)
apt-get install -y amazon-ssm-agent

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

# Iniciar e habilitar o SSM Agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Instalar AWS CLI v2 isolado em ambiente /tmp para downloads de buckets
cd /tmp
curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
ln -sf /usr/local/bin/aws /usr/bin/aws
rm -rf awscliv2.zip aws /usr/local/aws-cli/v2/current/dist/aws_completer

echo "✅ Bootstrapping concluído com sucesso."
