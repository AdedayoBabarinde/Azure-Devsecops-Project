# ArgoCD GitOps Setup

This directory contains ArgoCD configuration for GitOps deployment.

## ArgoCD Access Information

**ArgoCD Server URL:** http://20.242.220.204

**Default Credentials:**
- Username: `admin`
- Password: `xLr5AgC-hvW6XJvc`

**⚠️ IMPORTANT:** Change the admin password immediately after first login!

```bash
# Change password via CLI
argocd login 20.242.220.204
argocd account update-password
```

## Setup Instructions

### 1. Install ArgoCD CLI (Optional but Recommended)

**Windows (PowerShell):**
```powershell
# Download ArgoCD CLI
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
$url = "https://github.com/argoproj/argo-cd/releases/download/$version/argocd-windows-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile "$env:USERPROFILE\bin\argocd.exe"
```

**Linux/Mac:**
```bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

### 2. Login to ArgoCD

**Via CLI:**
```bash
argocd login 20.242.220.204 --username admin --password xLr5AgC-hvW6XJvc --insecure
argocd account update-password
```

**Via Web UI:**
1. Navigate to http://20.242.220.204
2. Login with admin/xLr5AgC-hvW6XJvc
3. Change password in User Info → Update Password

### 3. Configure Git Repository

Before deploying the application, update the `application.yaml` file with your Git repository URL:

```yaml
source:
  repoURL: https://github.com/<your-username>/Azure-Devsecops-Project.git
  targetRevision: add-github-action-workflows  # or main/master
```

### 4. Deploy the ArgoCD Application

```bash
kubectl apply -f argocd/application.yaml
```

Or via ArgoCD CLI:
```bash
argocd app create nimbus-app \
  --repo https://github.com/<your-username>/Azure-Devsecops-Project.git \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### 5. Monitor Application

**Via Web UI:**
- Navigate to http://20.242.220.204
- View the `nimbus-app` application

**Via CLI:**
```bash
# Get application status
argocd app get nimbus-app

# Watch application sync
argocd app sync nimbus-app --watch

# View application logs
argocd app logs nimbus-app
```

**Via kubectl:**
```bash
# Get all ArgoCD applications
kubectl get applications -n argocd

# Describe application
kubectl describe application nimbus-app -n argocd
```

## GitOps Workflow

With ArgoCD configured, your deployment workflow becomes:

1. **Make changes to Kubernetes manifests** in the `k8s/` directory
2. **Commit and push to Git**
   ```bash
   git add k8s/
   git commit -m "Update deployment configuration"
   git push
   ```
3. **ArgoCD automatically syncs** (within ~3 minutes or immediately with webhook)
4. **Monitor in ArgoCD UI** or CLI

### Manual Sync
If you don't want to wait for automatic sync:
```bash
argocd app sync nimbus-app
```

## ArgoCD Application Configuration

The `application.yaml` defines:

- **Source**: Your Git repository and path to manifests
- **Destination**: Target cluster and namespace
- **Sync Policy**: Automated with self-healing and auto-pruning
  - `prune: true` - Delete resources removed from Git
  - `selfHeal: true` - Auto-sync on cluster drift
  - `CreateNamespace: true` - Auto-create namespace

## Useful Commands

### Application Management
```bash
# List all applications
argocd app list

# Get application details
argocd app get nimbus-app

# Sync application
argocd app sync nimbus-app

# View application history
argocd app history nimbus-app

# Rollback to previous version
argocd app rollback nimbus-app <revision-number>

# Delete application
argocd app delete nimbus-app
```

### Application Monitoring
```bash
# Watch application sync status
argocd app wait nimbus-app

# View application resources
argocd app resources nimbus-app

# View application manifests
argocd app manifests nimbus-app

# View application diff
argocd app diff nimbus-app
```

### Repository Management
```bash
# Add private Git repository
argocd repo add https://github.com/<your-username>/Azure-Devsecops-Project.git \
  --username <username> \
  --password <password-or-token>

# List repositories
argocd repo list
```

## Setting Up GitHub Webhook (Optional)

For instant sync instead of waiting 3 minutes:

1. Go to your GitHub repository → Settings → Webhooks
2. Add webhook:
   - **Payload URL**: `http://20.242.220.204/api/webhook`
   - **Content type**: `application/json`
   - **Secret**: (leave empty or set in ArgoCD)
   - **Events**: Just the push event
3. Save webhook

## Integrating with CI/CD

Your existing GitHub Actions workflow can:
1. Build and push Docker image to ACR
2. Update image tag in `k8s/deployment.yaml`
3. Commit and push changes
4. ArgoCD automatically deploys the new version

Example workflow step:
```yaml
- name: Update Kubernetes manifests
  run: |
    sed -i 's|image: nimbusacrdev001.azurecr.io/nimbus-app:.*|image: nimbusacrdev001.azurecr.io/nimbus-app:${{ github.sha }}|' k8s/deployment.yaml
    git config user.name github-actions
    git config user.email github-actions@github.com
    git add k8s/deployment.yaml
    git commit -m "Update image tag to ${{ github.sha }}"
    git push
```

## Troubleshooting

### Application Out of Sync
```bash
# Check diff
argocd app diff nimbus-app

# Force sync
argocd app sync nimbus-app --force
```

### Sync Errors
```bash
# View application logs
argocd app logs nimbus-app --tail

# View events
kubectl describe application nimbus-app -n argocd
```

### Reset ArgoCD Admin Password
```bash
kubectl -n argocd patch secret argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
kubectl -n argocd rollout restart deployment argocd-server
```

## Security Best Practices

1. **Change default admin password immediately**
2. **Enable RBAC** for team access control
3. **Use private Git repositories** with SSH keys or tokens
4. **Enable HTTPS** with proper SSL certificates
5. **Implement webhook secrets** for GitHub integration
6. **Use sealed secrets** or external secret management for sensitive data

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [GitOps Principles](https://www.gitops.tech/)
