---
name: infra-robustez
description: Protocolo de Integridade para Infraestrutura como Código (IaC) e FinOps na AWS usando Terraform.
---

# 🛡️ Skill: Infra-Robustez (Augustus Protocol)

Esta Skill atua como o **Protocolo de Integridade Técnica** para o projeto CraneInspect, garantindo que toda a infraestrutura AWS seja provisionada com os mais altos padrões de engenharia, segurança e economia (FinOps).

## 🚀 Escopo de Atuação
Sempre que o usuário (Rodolfo) solicitar a criação, modificação ou destruição de recursos de infraestrutura AWS via Terraform, esta Skill deve ser ativada para validar os seguintes pilares:

### 1. Tríade da Robustez (Obrigatório)
Antes de qualquer `terraform plan` ou `apply`, os seguintes comandos DEVEM ser executados e validados:
*   `terraform fmt -recursive`: Garante a padronização estética do código HCL.
*   `terraform validate`: Valida a sintaxe e a configuração contra o provedor AWS.
*   `tflint`: Executa análise estática para capturar erros de configuração específicos da AWS.
*   `checkov`: Realiza scan de segurança para evitar configurações inseguras (ex: buckets públicos).

### 2. Governança de Tags & FinOps
Todos os recursos AWS devem herdar as `default_tags` definidas no provider. Nunca crie um recurso sem as tags mínimas:
*   `Project`: `CraneInspect`
*   `Environment`: `Dev` / `Staging` / `Prod`
*   `Owner`: `Rodolfo`
*   `ManagedBy`: `Terraform/Augustus`

**Regra FinOps:** Priorize o uso de **Spot Instances** para computação não crítica (EC2) e verifique se há recursos ociosos ou superdimensionados.

### 3. Modularidade e Estrutura (Arquiteto Sênior)
O código não deve residir em um único arquivo `main.tf`. A estrutura sugerida é:
*   `modules/`: Diretório contendo sub-módulos lógicos (vpc, s3, rds, ec2, cognito).
*   `main.tf`: Chamada dos módulos.
*   `variables.tf` / `outputs.tf`: Definições claras de entradas e saídas.
*   `providers.tf`: Configuração do AWS Provider e Backend (S3/DynamoDB para State Lock).

### 4. Gestão de Segredos "Zero-Leak"
*   **Proibição Absoluta:** Senhas, tokens ou ARNs sensíveis em texto claro nos arquivos `.tf`.
*   **Ação:** Utilize variáveis marcadas como `sensitive = true`.
*   **Armazenamento:** Segredos devem ser passados via arquivos `.tfvars` (protegidos no `.gitignore`) ou recuperados via **AWS Secrets Manager** / **Parameter Store (SSM)**.

### 5. Blindagem de Rede (Privacy by Design)
*   **Default Deny:** Recursos de backend (RDS, EC2 privadas) NUNCA devem ter IPs públicos.
*   **Acesso:** O acesso administrativo deve ser feito via **AWS SSM (Session Manager)**, eliminando a necessidade da porta 22 (SSH) aberta para a internet.
*   **Ingresso:** Apenas os Load Balancers (ALB) e CloudFront devem estar na sub-rede pública.

## 🛠️ Scripts Úteis (Sugeridos)

Crie um arquivo `scripts/validate_infra.sh` na raiz do projeto para automatizar estas verificações.

```bash
#!/bin/bash
echo "🔍 Iniciando Validação de Infra-Robustez..."
terraform fmt -recursive && \
terraform validate && \
tflint && \
checkov -d .
echo "✅ Protocolo concluído com sucesso."
```

## 📝 Auditoria de Decisões (ADRs)
Toda mudança arquitetural significativa deve ser acompanhada de um breve comentário ou arquivo MD justificando o "Porquê" da escolha (ex: "Uso de RDS Multi-AZ por alta disponibilidade" ou "Uso de Spot Instance para redução de custo em Dev").
