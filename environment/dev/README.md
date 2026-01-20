# Dev Environment Setup

This directory contains the Terraform configuration for the development environment.

## Prerequisites

1. **Azure CLI** installed and authenticated:
   ```bash
   az login
   az account show  # Verify your subscription
   ```

2. **Terraform** installed (v1.9.6 or later)

## Configuration

### Option 1: Use Azure CLI Default Subscription (Recommended for Local Dev)

If you're logged in with `az login`, Terraform will automatically use your default subscription:

```bash
terraform init
terraform plan -var-file="terraform.tfvars" -var="name=nimbus"
terraform apply -var-file="terraform.tfvars" -var="name=nimbus"
```

### Option 2: Use Environment Variable (Recommended for CI/CD)

Set the subscription ID as an environment variable:

**PowerShell:**
```powershell
$env:ARM_SUBSCRIPTION_ID = "your-subscription-id"
terraform apply -var-file="terraform.tfvars" -var="name=nimbus"
```

**Bash/Linux/Mac:**
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
terraform apply -var-file="terraform.tfvars" -var="name=nimbus"
```

**Using .env file:**
1. Copy `.env.example` to `.env` in the project root
2. Fill in your subscription ID
3. Source the file before running Terraform:
   ```powershell
   # PowerShell
   Get-Content ..\..\.env | ForEach-Object { if ($_ -match '^([^#][^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process') } }
   ```

## Security Best Practices

✅ **DO:**
- Use environment variables for sensitive values
- Use Azure CLI authentication for local development
- Keep `.env` files in `.gitignore`
- Use service principals for CI/CD pipelines

❌ **DON'T:**
- Hardcode subscription IDs in Terraform files
- Commit `.env` files or `.tfvars.local` files
- Share credentials in code or documentation

## Resources Created

- **Resource Group**: `rg-nimbus-dev`
- **Container Registry (ACR)**: `nimbusacrdev001`
- **Key Vault**: `nimbus-dev10111-kv`
- **Kubernetes Cluster (AKS)**: `aks-nimbus-dev`

## Troubleshooting

### Error: "subscription ID could not be determined"

**Solution**: Set the `ARM_SUBSCRIPTION_ID` environment variable or ensure you're logged in with Azure CLI:
```bash
az login
az account set --subscription "your-subscription-id"
```

### Error: "No registered resource provider found"

**Solution**: Register the required providers:
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerRegistry
```

