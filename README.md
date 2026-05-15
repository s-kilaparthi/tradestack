# TradeStack

> Production-grade real-time stock market monitoring platform

## Architecture
- **Data Source**: Yahoo Finance API
- **Streaming**: Apache Kafka
- **Storage**: PostgreSQL (historical) + Redis (live cache)
- **Visualization**: Grafana dashboards
- **Infrastructure**: AWS (Terraform)
- **Configuration**: Ansible
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Security**: DevSecOps (Bandit + Trivy + AWS Secrets Manager)
- **Monitoring**: Prometheus + Grafana

## Quick Start
```bash
./deploy.sh
```

## Tech Stack
![AWS](https://img.shields.io/badge/AWS-orange)
![Docker](https://img.shields.io/badge/Docker-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-blue)
![Kafka](https://img.shields.io/badge/Kafka-black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-blue)
![Grafana](https://img.shields.io/badge/Grafana-orange)
