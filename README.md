cat > README.md << 'EOF'
# DevOpsWithPankaj – Production-Grade EKS + RDS + ECS Runner

Fully automated EKS cluster with:
- Terraform + S3/DynamoDB backend (zero hardcoding)
- GitHub Actions with ECS self-hosted runners (scale to zero)
- RDS PostgreSQL with IAM authentication only (no passwords)
- Tag-based dynamic discovery
- Everything as code

---

## Part 1: Bootstrap Terraform Backend (Run ONCE)

> **You MUST run this before anything else**  
> Creates S3 bucket + DynamoDB table with proper security & tagging

```bash
# Clone and enter repo
git clone https://github.com/uddasp/devopswithpankaj.git
cd devopswithpankaj/bootstrap

# Make script executable
chmod +x create_backend.sh

# Run bootstrap (requires AWS CLI + admin permissions)
./create_backend.sh

---

