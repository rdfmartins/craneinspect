# CraneInspect

## Gestão Digital de Inspeções de Engenharia e Equipamentos Pesados

### 🏢 Visão Geral
O **CraneInspect** é uma plataforma moderna projetada para transformar o fluxo de trabalho de inspeções técnicas em campo, especificamente voltada para gruas e equipamentos de grande porte. O foco primordial é garantir a **integridade dos dados técnicos** e a **segurança das evidências fotográficas**, eliminando gargalos de comunicação entre o campo e a entrega final do relatório.

---

### ⚠️ O Cenário Atual (The Pain)
Atualmente, as inspeções manuais sofrem com## 🛠️ Tecnologias e Infraestrutura
**Base Arquitetural ('O Espelho da Realidade')**: O projeto adota uma abordagem minimalista de orquestração para focar em FinOps e blindagem, abolindo K8s ou ALBs no seu MVP de nicho.

### Cloud & SecOps (Infra as Code - Terraform)
*   Computação: EC2 (t3.micro Spot/On-Demand Free Tier limit-compliant). Acesso **exclusivamente** via AWS SSM Session Manager.
*   Containerização: Docker e Docker-Compose nativos na Instância, garantindo imutabilidade e zero-lock-in.
*   Armazenamento de Assets: AWS S3. Bloqueio total de acesso público (Block Public Access) – Exposição rigorosamente limitada por **Presigned-URLs**.
*   Persistência Relacional: AWS RDS PostgreSQL (db.t3.micro). Isolado em **Subnets Privadas** (sem IP público), acessível matematicamente apenas pela porta `5432` através do Security Group da própria EC2 (Defesa Profunda).
*   Governança: `Checkov` e `TFLint` integrados, assegurando que nenhum recurso suba sem compliance com os pilares da tríade de robustez., FinOps e Security-by-Design**, utilizando tecnologias de ponta em infraestrutura AWS.

#### **Infraestrutura como Código (IaC)**
*   **Terraform (v1.14.7):** Provisionamento escalável e reprodutível. Toda a infraestrutura é documentada em código, eliminando intervenções manuais (*Anti-ClickOps*).

#### **Cloud & Serviços AWS**
*   **Computação:** AWS EC2 operando com **Spot Instances** para otimização radical de custos (FinOps).
*   **Armazenamento:** AWS S3 com versionamento de objetos.
*   **Persistência:** PostgreSQL via **AWS RDS**.
*   **Identidade & Acesso:** AWS Cognito para gestão segura de perfis (Inspetores vs. Clientes).

#### **Desenvolvimento (Backend & Frontend)**
*   **Backend:** Python (FastAPI / Boto3) para lógica de negócio e integração com AWS SDK.
*   **Frontend:** Estratégia "Zero-Build" com HTML5, jQuery e Bootstrap, focando em simplicidade de manutenção e rapidez de carregamento no campo.

#### **Segurança First**
*   **Presigned URLs:** As fotos de inspeção nunca são expostas publicamente. O acesso é gerado sob demanda via tokens temporários de curta duração.

---

### 🔍 Situação Atual (O Espelho da Realidade)
Este projeto encontra-se em fase de **Inicialização de Infraestrutura (MVP)**.
- [x] Definição de Skill de Infra-Robustez.
- [x] Estrutura Inicial do Repositório Git.
- [x] Configuração de Ferramental de Linting (TFLint/Checkov).
- [ ] Módulo Terraform para Networking (VPC).
- [ ] Módulo Terraform para Armazenamento (S3).

---
*Rodolfo & Augustus*
