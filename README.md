## Infrastructure Setup

 ] ──> Deploys ──> [ AWS EKS Cluster ]
                                        │
             ┌──────────────────────────┴──────────────────────────┐
             ▼                                                     ▼
     [ Karpenter ]                                      [ NGINX Gateway Fabric ]
(Auto-scales GPU Nodes)                               (Kubernetes Gateway API)
  e.g., g5.xlarge (A10G)                                           │
             │                                                     ▼
             │                                           [ Open WebUI (Frontend) ]
             ▼                                                     │
[ Ollama (Inference Pods) ] <── Internal ClusterIP ────────────────┘

### What We've Deployed

#### ✅ Phase 1: Networking (Completed)
- **VPC**: `devopswithpankaj-vpc` (CIDR: 10.77.0.0/16)
  - 2 Public Subnets (us-east-1a, us-east-1b)
  - 2 Private Subnets (us-east-1a, us-east-1b)
  - NAT Gateway for private subnet egress
  - Internet Gateway for public subnet egress
  - Kubernetes tagging for ELB/internal-ELB discovery

#### ✅ Phase 2: EKS Cluster (Completed)
- **Cluster Name**: `ai-model-cluster`
- **Kubernetes Version**: 1.30
- **Node Configuration**:
  - Instance Type: t3.medium
  - Desired Nodes: 1
  - Min Nodes: 1
  - Max Nodes: 2
- **Security Groups**: Dedicated SGs for cluster and nodes
- **IAM Roles**: Cluster and Node group IAM roles with required policies

#### 🚀 Phase 3: Application Deployment (Next)
- Nginx Ingress Controller
- AI Model Deployment
- Web UI for AI Model Access

### Infrastructure as Code
- **Tool**: Terraform 1.9.0
- **State Management**: S3 (devopswithpankaj-tfstate) with file-based locking
- **CI/CD**: GitHub Actions with AWS OIDC authentication
- **Modules**:
  - `modules/vpc/` - VPC and networking
  - `modules/eks/` - EKS cluster and node groups

### Deployment via GitHub Actions
Push changes to `terraform/` directory on `main` branch to trigger automatic deployment.