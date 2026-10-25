# Enterprise Azure AKS DevSecOps Delivery Pipeline 🛡️☸️

[![DevSecOps Pipeline](https://github.com/Deenanath486/azure-aks-devsecops-pipeline/actions/workflows/devsecops.yml/badge.svg)](https://github.com/Deenanath486/azure-aks-devsecops-pipeline/actions/workflows/devsecops.yml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://azure.microsoft.com/en-us/products/kubernetes-service)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Helm](https://img.shields.io/badge/Packaging-Helm_v3-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Security](https://img.shields.io/badge/Security_Gates-Trivy_%7C_Gitleaks_%7C_SonarQube-success)](https://github.com/aquasecurity/trivy)

Production-grade **DevSecOps pipeline** for deploying containerized microservices to **Azure Kubernetes Service (AKS)** with **automated security gates** (Gitleaks, Bandit, Trivy, tfsec), Infrastructure as Code (Terraform), and Helm chart management.

---

## 🏗️ End-to-End DevSecOps Architecture

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                           CI/CD & DEVSECOPS SHIFT-LEFT PIPELINE                        │
 └────────────────────────────────────────────────────────────────────────────────────────┘
          │
          ▼
   [ Developer Push / PR ]
          │
          ├──► Gate 1: Secret Scan (Gitleaks) ─────────────► [ Block Hardcoded Credentials ]
          │
          ├──► Gate 2: SAST & Quality (Bandit / Flake8) ───► [ Code Vulnerabilities Analysis ]
          │
          ├──► Gate 3: IaC Scan (Trivy Config & tfsec) ────► [ Terraform Misconfigurations ]
          │
          ├──► Gate 4: Container CVE Scan (Trivy) ─────────► [ OS & Library Vulnerabilities ]
          │
          └──► Gate 5: Helm Lint & Validation ─────────────► [ Manifest Dry-Run Checks ]
                                                                      │
                                                                      ▼ (On Merge to Main)
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                               AZURE RUNTIME ENVIRONMENT                                │
 ├────────────────────────────────────────────────────────────────────────────────────────┤
 │                                                                                        │
 │  ┌──────────────────────────────────┐      Managed Identity     ┌───────────────────┐  │
 │  │ Azure Container Registry (ACR)   │ ◄──────────────────────── │ Azure AKS Cluster │  │
 │  │  - Hardened Microservice Image   │         (AcrPull)         │  - 2-5 Scaled VMSS│  │
 │  └──────────────────────────────────┘                           │  - Azure CNI VNet │  │
 │                                                                 │  - Non-Root Pods  │  │
 │  ┌──────────────────────────────────┐                           │  - Horizontal HPA │  │
 │  │ Azure Monitor & Log Analytics    │ ◄─────────────────────────┤  - Ingress + TLS  │  │
 │  └──────────────────────────────────┘      Container Insights   └───────────────────┘  │
 └────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── devsecops.yml           # Multi-stage CI/CD workflow with 5 security gates
├── app/
│   ├── app.py                      # Python Flask microservice (/healthz & /metrics)
│   └── requirements.txt            # App dependencies (Flask, prometheus-client)
├── charts/
│   └── microservice/               # Helm Chart for Kubernetes deployment
│       ├── Chart.yaml              # Metadata & Chart Version
│       ├── values.yaml             # Configurable limits, ingress, HPA, securityContext
│       └── templates/
│           ├── deployment.yaml     # Hardened deployment with liveness/readiness probes
│           ├── service.yaml        # ClusterIP service definition
│           ├── ingress.yaml        # TLS Ingress routing
│           ├── hpa.yaml            # Autoscaling based on CPU/Memory
│           └── serviceaccount.yaml # Least-privilege ServiceAccount
├── infra/                          # Modular Terraform for Cloud Infrastructure
│   ├── providers.tf                # AzureRM Provider (~> 3.100)
│   ├── variables.tf                # Parameterized configuration
│   ├── main.tf                     # Resource Group, VNet, Subnet, AKS, ACR & Identity
│   └── outputs.tf                  # AKS credentials, ACR login server
├── Dockerfile                      # Hardened multi-stage build running as non-root user
├── .gitignore                      # Ignore local state, secrets, and caches
└── README.md
```

---

## 🔒 Automated DevSecOps Security Gates

| Gate | Tool | Target | Enforcement Rule |
| :--- | :--- | :--- | :--- |
| **Gate 1: Secrets** | **Gitleaks** | Repository Commits | Fails build if API keys, passwords, or tokens are found. |
| **Gate 2: SAST** | **Bandit & Flake8** | Python Source Code | Detects common security issues (B101, SQLi, insecure imports). |
| **Gate 3: IaC** | **Trivy Config** | Terraform (`infra/`) | Flags unencrypted disks, public IPs, and insecure security groups. |
| **Gate 4: Container**| **Trivy Image Scan**| Docker Image | Scans OS packages and libraries; blocks `CRITICAL` CVEs. |
| **Gate 5: K8s** | **Helm Lint** | Helm Charts | Validates chart syntax, schema, and dry-run templates. |

---

## 🚀 Deployment Guide

### 1. Provision Cloud Infrastructure (Terraform)

```bash
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Connect to AKS Cluster

```bash
az aks get-credentials --resource-group rg-aks-devsecops-prod --name aks-devsecops-cluster
kubectl get nodes
```

### 3. Deploy via Helm

```bash
# Lint the chart
helm lint charts/microservice

# Dry-run test
helm template test-run charts/microservice

# Deploy to AKS
helm upgrade --install api-service charts/microservice \
  --namespace production \
  --create-namespace \
  --set image.tag="1.0.0"
```

### 4. Verify Running Pods & Endpoints

```bash
kubectl get pods -n production
kubectl get ingress -n production
curl http://<ingress-ip>/healthz
```

---

## 🛡️ Container Hardening Standards Applied

1. **Non-Root Execution**: Runs under unprivileged user `appuser (UID 10001)`.
2. **Minimal Base Image**: Uses `python:3.11-alpine` to minimize vulnerability surface area.
3. **Dropped Linux Capabilities**: `ALL` capabilities dropped in `securityContext`.
4. **Privilege Escalation**: `allowPrivilegeEscalation: false` strictly enforced.
5. **Observability**: Exposes `/metrics` endpoint for Prometheus scraping and Azure Monitor Container Insights.

---

## 👨‍💻 Author

**Deenanath Yadav**  
*DevOps & Azure Cloud Engineer*  
- **LinkedIn**: [linkedin.com/in/deenanath-yadav-495110146](https://www.linkedin.com/in/deenanath-yadav-495110146)  
- **Email**: [deenanathyadav106@gmail.com](mailto:deenanathyadav106@gmail.com)
