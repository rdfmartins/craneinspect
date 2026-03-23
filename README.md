# CraneInspect

## Gestão Digital de Inspeções de Engenharia e Equipamentos Pesados

### 🏢 Visão Geral
O **CraneInspect** é uma plataforma moderna projetada para transformar o fluxo de trabalho de inspeções técnicas em campo, especificamente voltada para gruas e equipamentos de grande porte. O foco primordial é garantir a **integridade dos dados técnicos** e a **segurança das evidências fotográficas**, eliminando gargalos de comunicação entre o campo e a entrega final do relatório.

---

### ⚠️ O Cenário Atual (The Pain)
Atualmente, as inspeções manuais sofrem com morosidade estrutural, riscos de perda de dados e falta de uma trilha de auditoria clara. O tempo de resposta entre a detecção de uma anormalidade técnica e a sua formalização em relatório pode comprometer a segurança operacional e a eficiência de custos.

---

### 🏛️ Arquitetura e Tech Stack
A solução foi arquitetada sob os pilares da **Robustez, FinOps e Security-by-Design**, utilizando tecnologias de ponta em infraestrutura AWS.

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
