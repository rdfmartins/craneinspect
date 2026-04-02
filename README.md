# CraneInspect

## Gestão Digital de Inspeções de Engenharia e Equipamentos Pesados

### 🏢 Visão Geral
O **CraneInspect** é uma plataforma projetada para transformar o fluxo de trabalho de inspeções técnicas em campo, voltada para gruas e equipamentos de grande porte. O foco é garantir a **integridade dos dados técnicos** e a **segurança das evidências fotográficas**, eliminando gargalos de comunicação entre o campo e a entrega final do relatório.

---

### ⚠️ O Cenário Atual (The Pain)
Atualmente, as inspeções manuais sofrem com morosidade estrutural, riscos de perda de dados e falta de uma trilha de auditoria clara. O tempo de resposta entre a detecção de uma anormalidade técnica e a sua formalização em relatório pode comprometer a segurança operacional e a eficiência de custos.

---

## 🛠️ Stack Tecnológico

**Base Arquitetural ('O Espelho da Realidade'):** O projeto adota uma abordagem minimalista de orquestração para focar em FinOps e segurança, abolindo K8s ou ALBs no MVP de nicho.

### Cloud & IaC (Terraform)
- **Computação:** EC2 (t3.micro). Acesso **exclusivamente** via AWS SSM Session Manager (porta 22 fechada).
- **Containerização:** Docker + Docker Compose nativos na instância (sem ECS/EKS).
- **Armazenamento de Assets:** AWS S3 com Block Public Access total. Exposição controlada por **Presigned URLs** de curta duração (TTL: 1h).
- **Persistência Relacional:** AWS RDS PostgreSQL (`db.t3.micro`) em Subnets Privadas, sem IP público. Acesso restrito à porta `5432` via Security Group da EC2.
- **Governança IaC:** `TFLint` e `Checkov` integrados (anti-ClickOps, Security-by-Design).

### Desenvolvimento
- **Backend:** Python 3.12 + **FastAPI** (API REST) + **SQLAlchemy** (ORM) + **Boto3** (AWS SDK).
- **Frontend:** Estratégia **Zero-Build** — HTML5, CSS Vanilla e JavaScript puro, sem Webpack/Babel. Servido via Nginx Alpine.
- **Banco local (Dev):** PostgreSQL 15 Alpine via Docker Compose.

### Segurança (SecOps Aplicado)
- **Presigned URLs:** Fotos de inspeção nunca são expostas publicamente. A URL de acesso é gerada **on-demand** pelo FastAPI e expira em 1 hora.
- **Zero Hardcode:** Credenciais AWS e senhas do banco injetadas exclusivamente via variáveis de ambiente. Em produção, resolvidas pela IAM Role da EC2.
- **Container não-root:** O processo da aplicação roda como `appuser` (sem privilégios root) dentro do container.
- **Validação de MIME:** O endpoint de upload rejeita tipos de arquivo não permitidos antes de qualquer interação com o S3.

---

## 🗂️ Estrutura do Projeto

```
craneinspect/
├── terraform/           # Infraestrutura como Código (VPC, EC2, RDS, S3)
├── backend/
│   ├── main.py          # Entrypoint FastAPI + rotas REST
│   ├── models.py        # Entidades SQLAlchemy (Inspection, InspectionPhoto)
│   ├── schemas.py       # Schemas Pydantic (validação de I/O)
│   ├── database.py      # Engine SQLAlchemy + Dependency Injection
│   ├── s3_service.py    # Camada de serviço S3/Boto3 (upload, Presigned URL, delete)
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   └── index.html       # Interface Zero-Build (HTML5 + CSS + JS)
├── docker-compose.yml   # Orquestração local (backend, db, frontend)
└── .env                 # Variáveis locais (NÃO versionado)
```

---

### 🔍 Situação Atual

**Fase 1 (Fundação de Infraestrutura — IaC):** ✅ Concluída
- [x] Módulo Terraform: Networking (VPC, Subnets, IGW, Route Tables).
- [x] Módulo Terraform: Computação (EC2 + SSM).
- [x] Módulo Terraform: Armazenamento (S3 + Lifecycle + Versionamento).
- [x] Módulo Terraform: Persistência (RDS PostgreSQL, Subnets Privadas).

**Fase 2 (Arquitetura da Aplicação):** 🔄 Em progresso
- [x] Containerização: `docker-compose.yml` com backend, db e frontend.
- [x] `Dockerfile` da API (Python 3.12 Slim, non-root user, hot reload).
- [x] ORM: Modelos SQLAlchemy (`Inspection`, `InspectionPhoto`).
- [x] Schemas Pydantic de validação de Input/Output.
- [x] API REST: `POST /inspections`, `GET /inspections`, `GET /inspections/{id}`.
- [x] Integração S3/Boto3: upload privado + geração de Presigned URL on-demand.
- [x] API REST: `POST /inspections/{id}/photos`, `GET /photos/{id}/url`.
- [x] Interface Zero-Build (HTML5/CSS/JS) com formulário, listagem e upload de fotos.
- [ ] Provisionamento do bucket S3 via `terraform apply` (ciclo de upload real).

---

### ⚠️ Limitações e Escopo de Portfólio

> Este projeto é um **MVP de Portfólio** não destinado à produção pública. As limitações de design são decisões intencionais de FinOps:
> - Sem autenticação de usuários (Cognito planejado para fase futura).
> - Sem HTTPS (requer ALB ou Certbot — removido por FinOps nesta fase).
> - Sem alta disponibilidade (Multi-AZ desativado no RDS, sem ASG no EC2).

---

*Rodolfo & Augustus*
