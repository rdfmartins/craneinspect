# 📜 Memorial de Obra - CraneInspect

Este documento serve como o **Plano de Execução e Registro Arquitetural** do projeto. Ele contém as decisões tomadas, o progresso técnico e o backlog para melhorias futuras.

---

## 🏛️ Registro de Decisões Arquiteturais (ADRs)

### ADR-000: Arquitetura Base e Stack Tecnológico (The Foundation)
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** O core tecnológico do projeto CraneInspect será composto por: **Infraestrutura via Terraform**, **Computação EC2 (Spot)**, **Armazenamento S3 via Presigned URLs**, **Backend em Python (FastAPI)**, e **Frontend 'Zero-Build' (HTML5 + jQuery + Bootstrap via CDN)**.
- **O 'Porquê' (The Pain):** Soluções corporativas comuns (K8s, SPAs complexos como React) adicionam uma camada de sobrecarga cognitiva e custos insustentáveis para um MVP voltado a um nicho restrito (3 usuários).
- **Valor Agregado (A Racionalidade do Arquiteto):**
  - **Terraform:** Imutabilidade. Protege o portfólio contra "ClickOps". O projeto inteiro pode ser reconstruído na AWS em menos de 5 minutos, servindo como uma prova tangível de skill de Cloud Engineering.
  - **AWS EC2 (Spot) & S3:** Foco maníaco em FinOps (custos reduzidos a cêntimos) + segurança isolada via SSM. O S3 retira a carga de persistência da EC2 (Coração da arquitetura Data-Driven).
  - **Python (FastAPI) & Boto3:** O padrão da indústria para Cloud Native. Extremamente rápido, assíncrono e domina completamente o SDK da AWS (Boto3) para a geração de tokens seguros do S3.
  - **Frontend Zero-Build (jQuery + Bootstrap CDN):** Menos ferramentas para quebrar. Simplicidade bruta que foca o holofote na **Infraestrutura Cloud e Segurança**. jQuery é o padrão de facto em sistemas corporativos de campo, e Bootstrap garante consistência visual sem custo cognitivo.
- **⛔ Regras Proibidas no Frontend (Não Negociável):**
  - **PROIBIDO:** `npm install`, `yarn`, `pnpm` ou qualquer gerenciador de pacotes Node.
  - **PROIBIDO:** Ferramentas de build como Webpack, Vite, Parcel ou Babel.
  - **PROIBIDO:** Frameworks SPA como React, Vue ou Angular.
  - **PERMITIDO:** jQuery e Bootstrap **exclusivamente via CDN** (`<script src="...cdn...">`).
  - **PERMITIDO:** JavaScript puro (ES6+) como complemento ao jQuery onde mais legível.

- **O 'Porquê' (The Pain):** Soluções corporativas comuns (K8s, SPAs complexos como React) adicionam uma camada de sobrecarga cognitiva e custos insustentáveis para um MVP voltado a um nicho restrito (3 usuários).
- **Valor Agregado (A Racionalidade do Arquiteto):**
  - **Terraform:** Imutabilidade. Protege o portfólio contra "ClickOps". O projeto inteiro pode ser reconstruído na AWS em menos de 5 minutos, servindo como uma prova tangível de skill de Cloud Engineering.
  - **AWS EC2 (Spot) & S3:** Foco maníaco em FinOps (custos reduzidos a cêntimos) + segurança isolada via SSM. O S3 retira a carga de persistência da EC2 (Coração da arquitetura Data-Driven).
  - **Python (FastAPI) & Boto3:** O padrão da indústria para Cloud Native. Extremamente rápido, assíncrono e domina completamente o SDK da AWS (Boto3) para a geração de tokens seguros do S3.
  - **Frontend Zero-Build:** Menos ferramentas para quebrar (sem Webpack/Babel). Simplicidade bruta que foca o holofote na **Infraestrutura Cloud e Segurança**, provando que o Arquiteto domina a base da pirâmide (The Core) antes da parte visual.

### ADR-001: Remoção do ALB (Application Load Balancer)
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** Optamos por não utilizar um Application Load Balancer (ALB) nesta fase inicial do MVP.
- **Justificativa (FinOps):** Com uma base de usuários projetada de 1-3 usuários, o custo fixo de um ALB (~$16/mês) não se justifica. Utilizaremos o acesso direto via Elastic IP (EIP) ou DNS direto na instância EC2.
- **Impacto:** Menor custo operacional; maior responsabilidade no gerenciamento de Security Groups para a instância individual.

### ADR-002: Acesso Administrativo via AWS SSM
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** O acesso ao terminal das instâncias EC2 será realizado exclusivamente via **AWS Systems Manager (SSM) Session Manager**.
- **Justificativa (Segurança):** Elimina a necessidade de abrir a porta 22 (SSH) para a internet externa e dispensa o gerenciamento de chaves `.pem` locais.

### ADR-003: Containerização MVP com Docker-Compose
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** A aplicação (Backend FastAPI/Flask e Frontend Estático) será executada em contêineres gerenciados localmente por **Docker-Compose** dentro da EC2, sem orquestradores como EKS/ECS.
- **Justificativa (FinOps/Simplicidade):** Garante a portabilidade e facilidade de atualização (Imutabilidade) entre ambientes locais e Cloud, sem overhead de custos ou complexidade desnecessária de um cluster Kubernetes para 1 a 3 administradores/inspetores.

### ADR-004: Políticas de Segurança e Lifecycle no S3 (FinOps & Data Integrity)
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** O bucket do S3 foi criado fechado para a internet e configurado com transição de objetos para `STANDARD_IA` após 30 dias. Adição de versionamento de arquivos.
- **O 'Porquê' / O Problema ("The Pain"):** Fotos de inspeção antigas não são mais consultadas após a entrega do relatório e consumiriam o espaço e o custo da camada mais cara do S3. Ao mesmo tempo, exclusões acidentais poderiam gerar perda de prova material das gruas inspecionadas.
- **Valor Agregado (FinOps/SecOps):** A transição automática garante redução gradual do custo da fatura da AWS mensal, e as versões blindadas no backend previnem vulnerabilidades de exclusão acidental ou intencional (Proteção). O acesso só é garantido via Presigned-URL temporária na API do aplicativo.

### ADR-005: Banco de Dados Relacional AWS RDS PostgreSQL (Isolamento de Rede)
- **Data:** 24/03/2026
- **Status:** Aprovado
- **Decisão:** Adotamos o PostgreSQL no AWS RDS (`db.t3.micro` Free Tier) instanciado em Subnets Privadas (`aws_db_subnet_group`) e sem IP Público. Multi-AZ foi desativado.
- **O 'Porquê' (The Pain):** Bancos de dados expostos publicamente são o vetor #1 de vazamento de dados corporativos e ataques de ransomware. Ao mesmo tempo, Multi-AZ dobra os custos ociosos para MVPs.
- **Valor Agregado (FinOps/SecOps):** A escolha do `t3.micro` foca na extrema redução do billing. A proteção via `aws_db_subnet_group` e `aws_security_group` restrito a porta 5432 significa que é *matematicamente impossível* acessar o banco pela internet, garantindo que apenas a nossa EC2 (Docker-Backend) tenha o poder de falar com o PostgreSQL (Defesa Profunda).

### ADR-006: Arquitetura de Software Core (Fase 2 - The Reality Check)
- **Data:** 25/03/2026
- **Status:** Aprovado
- **Decisão:** A adoção do "Feijão com Arroz Perfeito": PostgreSQL (B-Tree + Eager Loading para zero `N+1` Queries) processado via API FastAPI monolítica utilizando suas `BackgroundTasks` nativas, sem Brokers de Mensageria (ex: Redis/RabbitMQ). Paginação Server-Side SQL clássica. O trafego de mídia ocorre via `boto3` com *Presigned URLs Diretas* descartando o setup precoce de CDN (CloudFront).
- **O 'Porquê' (The Pain):** O dimensionamento MVP foca em uma frota finita (~110 gruas). Soluções de arquitetura de big-tech distorceriam a nossa realidade, gerando "Overselling" da solução para o portfólio e, criticamente, uma degradação de Memória RAM na limitada instância EC2 `t3`. 
- **Valor Agregado (A Racionalidade do Arquiteto):** Estabilidade brutal. Cortando a adoção desenfreada de filas e CDN assíncronos, garantimos que a nossa aplicação rode de forma coesa na mesma thread consumindo memória residual, mantendo a estabilidade de infra para o usuário em campo.

### ADR-007: CORS e Separação de Origem (Frontend Zero-Build)
- **Data:** 02/04/2026
- **Status:** Aprovado
- **Decisão:** Habilitado `CORSMiddleware` no FastAPI restringindo origens permitidas a `localhost:8080` (Nginx dev) e preparado para o domínio de produção EC2 no futuro.
- **O 'Porquê' (The Pain):** O frontend servido pelo Nginx (porta 8080) e a API no Uvicorn (porta 8000) são origens distintas. Sem CORS explícito, o browser bloqueia todas as requisições em nível de segurança, tornando a interface inoperante.
- **Valor Agregado (SecOps):** A lista de origens é restritiva e explícita. Nenhum `allow_origins=["*"]` (wildcard irresponsável) foi adotado, garantindo que apenas origens conhecidas possam consumir a API.

---

## 🏗️ Estado Atual do Projeto

### Fase 1: Fundação de Infraestrutura Cloud — ✅ Concluída
- [x] Definição de CIDR e Módulo VPC (Networking).
- [x] Criação de Subnets Públicas e Privadas.
- [x] Configuração de Internet Gateway (IGW) e Route Tables.
- [x] Módulo Terraform para Computação (EC2 via SSM).
- [x] Módulo Terraform para Armazenamento (S3 + Lifecycle + Versionamento).
- [x] Módulo Terraform para Persistência (RDS PostgreSQL, Subnets Privadas).

### Fase 2: Arquitetura da Aplicação — 🔄 Em Progresso
- [x] `docker-compose.yml` com serviços: `backend`, `db` (PostgreSQL 15 Alpine) e `frontend` (Nginx Alpine).
- [x] `Dockerfile` do backend: Python 3.12 Slim, non-root user (`appuser`), hot reload via Uvicorn.
- [x] `database.py`: Engine SQLAlchemy com Dependency Injection para FastAPI.
- [x] `models.py`: Entidades `Inspection` e `InspectionPhoto` com cascade delete e relação bidirecional.
- [x] `schemas.py`: Schemas Pydantic de Input/Output com validação de campos e serialização segura.
- [x] API REST: `POST /inspections`, `GET /inspections`, `GET /inspections/{id}`.
- [x] `s3_service.py`: Service Layer para upload privado, Presigned URL (TTL 1h) e delete de objetos S3.
- [x] API REST: `POST /inspections/{id}/photos` (multipart + validação MIME) e `GET /photos/{id}/url`.
- [x] `frontend/index.html`: Interface Zero-Build (**jQuery 3.7 + Bootstrap 5 via CDN**) com criação de vistorias, listagem paginada e upload de evidências fotográficas.
- [x] Fix: Hash SRI inválido do Bootstrap JS removido (bloqueava carregamento da lista).
- [ ] **`terraform apply`**: Provisionamento do bucket S3 real — **PRÓXIMO PASSO**.


---

## 🎯 Próxima Sessão — Ponto de Retomada

**Sessão encerrada em:** 02/04/2026 às 15:44

**O que fazer ao retomar:**
1. Autenticar na AWS: `aws sso login` (ou `aws configure` se usar chaves de acesso)
2. Verificar se os containers estão no ar: `docker compose ps`
   - Se não estiverem: `docker compose up -d`
3. Navegar para o módulo S3: `cd terraform/`
4. Conferir o plano antes de aplicar: `terraform plan`
5. Provisionar o bucket: `terraform apply`
6. Configurar no `.env` local: `S3_BUCKET_NAME=<nome-do-bucket-gerado>`
7. Testar o upload real em `http://localhost:8080`

**Pré-requisito de Frontend (Próxima iteração):**
- Ao evoluir a UI, usar `Projetos_Autoresearch_AWS.md` como **referência de identidade temática e terminologia** ("The Pain", FinOps, métricas de custo/performance). A linguagem e os padrões visuais do frontend devem refletir o vocabulário desse documento.


- `craneinspect_backend` → ✅ Online (porta 8000)
- `craneinspect_db`      → ✅ Healthy (PostgreSQL 15)
- `craneinspect_frontend`→ ✅ Online (porta 8080, Nginx)


*Estimativa de custos para o MVP:*
- **RDS (PogreSQL t3.micro):** ~$13.00/mês (Free Tier se elegível).
- **EC2 (t3.medium Spot):** ~$0.015/hora (~$10.80/mês se 24/7).
- **S3 (Storage + Request):** ~$1.00 - $3.00/mês (Variavel).
- **ALB (Removido):** $0.00 (Economia de ~$16.00).

---

## 🚀 Backlog de Melhorias (Para Análise Posterior)
1.  **Refatoração para ALB + ASG:** Quando a base superar 10 usuários simultâneos, para garantir alta disponibilidade e Terminação SSL.
2.  **CDN CloudFront:** Implementar para cache de imagens pesadas de inspeção no S3, reduzindo latência e transfer-out (FinOps).
3.  **WAF (Web Application Firewall):** Reforço de segurança contra SQL Injection e ataques automatizados.

---
*Atualizado por: Augustus (Senior Architect) — 02/04/2026*
