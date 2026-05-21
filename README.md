# TradeStack 📈
> A production-grade real-time stock market monitoring platform built to demonstrate end-to-end DevOps practices.

## What is TradeStack?

TradeStack is a real-time stock market monitoring platform that fetches live stock prices from Yahoo Finance, streams them through Apache Kafka, stores them in PostgreSQL, caches them in Redis, and visualizes them in Grafana dashboards.

But honestly? The stock monitoring is just the use case. The real goal was to build a **complete DevOps pipeline** — from local development to cloud deployment — using industry-standard tools and practices.

This project covers everything: containerization, CI/CD, infrastructure as code, configuration management, container orchestration, monitoring, and security.

---

## Architecture

Yahoo Finance API
↓
Producer (Python)
↓
Apache Kafka
↓
Consumer (Python)
↓
PostgreSQL (historical) + Redis (live cache)
↓
Grafana Dashboard

**CI/CD Flow:**

git push → GitHub Actions CI
→ Run Tests (Pytest)
→ Security Scan (Bandit)
→ Build Images
→ Scan Images (Trivy)
→ Push to Docker Hub
↓
merge to main
↓
GitHub Actions CD
→ SSH into EC2
→ Pull latest images
→ Restart containers
→ TradeStack updated!

---

## Tech Stack

| Tool | Purpose | Why I chose it |
|------|---------|----------------|
| **Python** | Producer & Consumer | Simple, great library support |
| **Apache Kafka** | Message streaming | Industry standard for real-time data pipelines |
| **PostgreSQL** | Historical storage | Reliable, SQL-based, great for time-series data |
| **Redis** | Live cache | In-memory, blazing fast for current prices |
| **Docker** | Containerization | Consistent environments everywhere |
| **Docker Compose** | Local orchestration | Simple multi-container management |
| **GitHub Actions** | CI/CD pipeline | Native GitHub integration, free for public repos |
| **Terraform** | Infrastructure as Code | Reproducible AWS infrastructure |
| **Ansible** | Configuration management | Automated server setup |
| **Kubernetes** | Container orchestration | Production-grade container management |
| **Prometheus** | Metrics collection | Industry standard monitoring |
| **Grafana** | Visualization | Beautiful dashboards for stock data |
| **AWS EC2** | Cloud hosting | Scalable compute |
| **AWS Secrets Manager** | Secret management | Secure credential storage |
| **Bandit** | Python security scanning | Catches security issues in code |
| **Trivy** | Container scanning | Finds vulnerabilities in Docker images |

---

## Features

- 🔄 **Real-time data pipeline** — fetches stock prices every 10 seconds
- 📊 **Live Grafana dashboard** — visualizes AAPL, GOOGL, TSLA, MSFT, AMZN
- 🚀 **Automated CI/CD** — push code, tests run, images build, server updates
- ☁️ **Cloud deployed** — running on AWS EC2 with Terraform
- 🔒 **Security first** — Bandit, Trivy, AWS Secrets Manager
- 🎯 **Kubernetes ready** — manifests tested on Minikube
- 📝 **Infrastructure as Code** — everything reproducible from scratch

---

## Project Structure


tradestack/
├── services/
│   ├── producer/          # Fetches prices from Yahoo Finance → Kafka
│   │   ├── producer.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── test_producer.py
│   └── consumer/          # Reads from Kafka → PostgreSQL + Redis
│       ├── consumer.py
│       ├── requirements.txt
│       ├── Dockerfile
│       └── test_consumer.py
├── infrastructure/
│   ├── terraform/         # AWS infrastructure (EC2, Security Group, EIP)
│   ├── ansible/           # Server configuration (Docker, dependencies)
│   └── deploy-infra.sh    # One command deployment script
├── k8s/                   # Kubernetes manifests
├── monitoring/
│   ├── prometheus/        # Prometheus config
│   └── grafana/           # Dashboards + provisioning
├── .github/
│   └── workflows/
│       ├── ci.yml         # CI pipeline (test, scan, build)
│       └── deploy.yml     # CD pipeline (deploy to EC2)
└── docker-compose.yml     # Local development

---

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Python 3.11+
- AWS CLI configured
- Terraform installed
- Ansible installed

### Run Locally

```bash
git clone https://github.com/s-kilaparthi/tradestack.git
cd tradestack

# Copy environment file
cp .env.example .env

# Start all services
docker-compose up -d

# Check everything is running
docker-compose ps
```

### Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| Grafana | `admin` | set in `.env` file |
| PostgreSQL | `tradestack` | set in `.env` file |

> Default password is `tradestack123` for local development.
> Change via `.env` file before deploying to production!

### Access Services

| Service | URL |
|---------|-----|
| Grafana Dashboard | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |

---

## Deploy to AWS

### Prerequisites
- AWS CLI configured with EC2 and S3 permissions
- IAM Role `instanceRole` created with SecretsManager read access
- Ansible Vault password for secrets
- SSH key pair `karthik-devops-key` in AWS

### One Command Deployment

```bash
./infrastructure/deploy-infra.sh
```

This will:
1. Create EC2 instance with Terraform
2. Automatically update Ansible inventory with new IP
3. Configure server with Ansible (Docker, swap, dependencies)
4. Pull Docker images and start all containers
5. Show Grafana and Prometheus URLs when complete

> ⚠️ **Note:** IAM Role must be created manually in AWS Console
> before first deployment due to IAM permission constraints.

### Stop EC2 (save costs)

```bash
aws ec2 stop-instances --instance-ids <instance-id> --region us-east-2
```

### Start EC2

```bash
aws ec2 start-instances --instance-ids <instance-id> --region us-east-2
```

### GitHub Secrets Required

Before CD pipeline can deploy, add these secrets to your GitHub repo:
`Settings → Secrets and variables → Actions → New repository secret`

| Secret | Description |
|--------|-------------|
| `EC2_HOST` | Your EC2 public IP (update after each new instance) |
| `EC2_USER` | `ubuntu` |
| `EC2_SSH_KEY` | Contents of your `.pem` key file |
| `DB_HOST` | `postgres` |
| `DB_NAME` | `tradestack` |
| `DB_USER` | `tradestack` |
| `DB_PASSWORD` | Your database password |
| `REDIS_HOST` | `redis` |
| `REDIS_PORT` | `6379` |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token |

> ⚠️ **Important:** Update `EC2_HOST` secret every time you create 
> a new EC2 instance with Terraform!

---

## CI/CD Pipeline

Every push to `dev` triggers:

Run Tests → Security Scan → Build Images → Push to Docker Hub

Every merge to `main` triggers:Every merge to `main` triggers:

Deploy to AWS EC2 → Pull latest images → Restart containers

Branch protection ensures no code reaches production without passing all checks.

### Branch Strategy

dev     → active development
staging → pre-production testing
main    → production (auto-deploys to AWS)

---

## Security

- **Bandit** — scans Python code for security vulnerabilities on every commit
- **Trivy** — scans Docker images for CVEs before pushing to Docker Hub
- **AWS Secrets Manager** — database credentials stored securely, never in code
- **Branch protection** — no direct pushes to `main` or `staging`
- **Ansible Vault** — encrypted secrets for server configuration
- **Environment variables** — no hardcoded secrets anywhere in codebase

---

## Monitoring

- **Prometheus** — scrapes metrics every 15 seconds
- **Grafana** — real-time stock price dashboard with:
  - AAPL price over time
  - All 5 stocks comparison chart
  - Current prices table

---

## Infrastructure

AWS Resources:
├── EC2 (t3.small)        — runs all Docker containers
├── Security Group         — firewall rules (ports 22, 3000, 9090)
├── Elastic IP             — fixed public IP address
├── S3 Bucket              — Terraform state storage
└── IAM Role               — EC2 permissions for Secrets Manager

Full infrastructure + configuration deployed with one command:
```bash
./infrastructure/deploy-infra.sh
```

Or deploy infrastructure only:
```bash
cd infrastructure/terraform
terraform apply -auto-approve
```
---

## Kubernetes

Kubernetes manifests are available in `k8s/` directory, tested on Minikube:

```bash
# Start Minikube
minikube start --driver=docker

# Deploy all services
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/postgres-deployment.yml
kubectl apply -f k8s/redis-deployment.yml
kubectl apply -f k8s/zookeeper-deployment.yml
kubectl apply -f k8s/kafka-deployment.yml
kubectl apply -f k8s/producer-deployment.yml
kubectl apply -f k8s/consumer-deployment.yml
kubectl apply -f k8s/grafana-deployment.yml

# Check pods
kubectl get pods
```

> Ready for EKS deployment in production environments.

---

## What I Learned

Building TradeStack taught me that DevOps isn't just about tools — it's about thinking holistically about software delivery. Every decision has a reason:

- Why Kafka instead of direct DB writes? **Decoupling** — producer and consumer can scale independently
- Why Redis alongside PostgreSQL? **Speed** — current prices need millisecond access
- Why Ansible after Terraform? **Separation of concerns** — infrastructure vs configuration
- Why GitHub Actions? **Native integration** — no extra tooling needed
- Why AWS Secrets Manager? **Security** — credentials should never live in code

The hardest part wasn't the tools — it was understanding **why** each piece exists and how they work together.

---

## Author

**Siva Karthik Kilaparthi**
- GitHub: [@s-kilaparthi](https://github.com/s-kilaparthi)
- LinkedIn: [Your LinkedIn URL]

---

## License

MIT License — feel free to use this as a reference for your own DevOps projects!
