# ArgoCD GitOps Setup Guide

## What is GitOps?

GitOps is a way of managing Kubernetes deployments where:
- **Git is the single source of truth** for your infrastructure and applications
- **Automated tools** (like ArgoCD) sync your cluster state with Git
- **Changes to Git** automatically trigger deployments
- **Easy rollbacks** by reverting Git commits

## Architecture Overview

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│  GitHub Repo    │────▶│   ArgoCD     │────▶│  AKS Cluster│
│  (k8s/*.yaml)   │     │  (Operator)  │     │  (Running   │
└─────────────────┘     └──────────────┘     │   Pods)     │
                               ▲              └─────────────┘
                               │
                        Continuously monitors
                        and syncs every 3 min
```

## Current Setup

### 1. ArgoCD Installed on AKS ✅
- **Namespace**: `argocd`
- **UI Access**: http://20.242.220.204

### 2. Files Created
```
argocd/
├── application.yaml          # ArgoCD app configuration
├── README.md                 # Detailed documentation
└── SETUP-GUIDE.md           # This file

.github/workflows/
├── deploy.yaml              # Original workflow (still works)
└── deploy-gitops.yaml       # New GitOps workflow
```

## Quick Start

### Step 1: Update Git Repository URL

Edit `argocd/application.yaml` and replace `<your-username>` with your GitHub username:

```yaml
source:
  repoURL: https://github.com/<your-username>/Azure-Devsecops-Project.git
  targetRevision: add-github-action-workflows  # or main
```

### Step 2: Apply ArgoCD Application

```powershell
kubectl apply -f argocd/application.yaml
```

### Step 3: Access ArgoCD UI

1. Open browser: http://20.242.220.204
2. Login: 
3. You should see `nimbus-app` application

### Step 4: Change Admin Password (Important!)

```bash
# Via CLI
argocd login 20.242.220.204 --username admin --password insert password

# Via UI
# User Info → Update Password
```

## GitOps Workflow Comparison

### Before GitOps (Original Workflow)
```yaml
GitHub Push → Build Image → Push to ACR → kubectl apply → Deploy
```
- GitHub Actions directly deploys to AKS
- Manual intervention needed for rollbacks
- Cluster state can drift from Git

### After GitOps (New Workflow)
```yaml
GitHub Push → Build Image → Push to ACR → Update k8s/ manifests → Git commit
                                                                        ↓
                                                  ArgoCD detects change ←┘
                                                                        ↓
                                                  ArgoCD syncs to AKS ←┘
```
- GitHub Actions only builds and updates Git
- ArgoCD handles all deployments
- Automatic drift detection and correction
- Easy rollbacks via Git history

## Benefits of GitOps with ArgoCD

1. **Single Source of Truth**: Git contains exact cluster state
2. **Automated Sync**: Changes auto-deploy within 3 minutes
3. **Self-Healing**: ArgoCD corrects manual changes
4. **Easy Rollbacks**: `git revert` to roll back
5. **Audit Trail**: Full Git history of changes
6. **Declarative**: Define desired state, not steps
7. **Multi-Environment**: Same process for dev/staging/prod

## Next Steps

### 1. Test the GitOps Workflow

Make a change to your application:

```bash
# 1. Make a code change
cd app/src
# ... edit some files ...

# 2. Commit and push (triggers CI/CD)
git add .
git commit -m "feat: add new feature"
git push

# 3. Watch the workflow
# - GitHub Actions builds image
# - GitHub Actions updates k8s/deployment.yaml
# - ArgoCD detects change and syncs
# - New version deploys automatically
```

### 2. Monitor in ArgoCD

```bash
# Via CLI
argocd app get nimbus-app
argocd app sync nimbus-app --watch

# Via UI
# Navigate to http://20.242.220.204
```

### 3. Configure GitHub Webhook (Optional)

For instant sync instead of waiting 3 minutes:

1. Go to GitHub Repo → Settings → Webhooks
2. Add webhook:
   - **URL**: `http://20.242.220.204/api/webhook`
   - **Content type**: `application/json`
   - **Events**: Push events
3. Save

### 4. Set Up Multiple Environments

Create environment-specific folders:

```
k8s/
├── base/              # Common resources
│   ├── deployment.yaml
│   └── service.yaml
├── overlays/
│   ├── dev/          # Dev-specific config
│   ├── staging/      # Staging config
│   └── prod/         # Production config
```

Then create separate ArgoCD apps for each environment.

### 5. Implement Progressive Delivery

Use ArgoCD with:
- **Argo Rollouts** for blue-green and canary deployments
- **Flagger** for automated progressive delivery
- **Analysis templates** for automated rollback

## Troubleshooting

### Application Not Syncing
```bash
# Check application status
kubectl get application nimbus-app -n argocd

# View detailed status
argocd app get nimbus-app

# Force sync
argocd app sync nimbus-app --force
```

### Sync Failed
```bash
# View sync errors
argocd app get nimbus-app | grep -A 20 "Message:"

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100
```

### Can't Access ArgoCD UI
```bash
# Check service
kubectl get svc argocd-server -n argocd

# Port forward as alternative
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Then access: https://localhost:8080
```

### Image Not Updating
```bash
# Check if manifest was updated in Git
cat k8s/deployment.yaml | grep image:

# Check ArgoCD detected the change
argocd app diff nimbus-app

# Force refresh
argocd app get nimbus-app --refresh
```

## Security Best Practices

1. ✅ **Change admin password** immediately
2. ✅ **Use HTTPS** with proper certificates (production)
3. ✅ **Enable RBAC** for team access
4. ✅ **Use SSH keys** or deploy tokens for private repos
5. ✅ **Implement webhook secrets** for GitHub webhooks
6. ✅ **Use sealed secrets** for sensitive data
7. ✅ **Enable audit logging**
8. ✅ **Implement network policies**

## Production Considerations

### High Availability
```bash
# Scale ArgoCD components
kubectl scale deployment argocd-server -n argocd --replicas=3
kubectl scale deployment argocd-repo-server -n argocd --replicas=3
```

### Monitoring
- Integrate with Prometheus for metrics
- Set up alerts for sync failures
- Monitor application health

### Disaster Recovery
- Backup ArgoCD configuration
- Document restore procedures
- Test rollback procedures regularly

## Commands Reference

```bash
# Install ArgoCD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Login
argocd login 20.242.220.204 --insecure

# Create application
kubectl apply -f argocd/application.yaml

# List applications
argocd app list

# Get application details
argocd app get nimbus-app

# Sync application
argocd app sync nimbus-app

# Watch sync
argocd app sync nimbus-app --watch

# Rollback
argocd app rollback nimbus-app <revision>

# Delete application
argocd app delete nimbus-app
```

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Guide](https://www.gitops.tech/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/)
- [Kustomize for multi-env](https://kustomize.io/)

## Support

For issues or questions:
1. Check ArgoCD logs
2. Review application events
3. Consult ArgoCD documentation
4. Check GitHub Actions workflow logs

---

**Current Status**: ArgoCD installed and ready. Next step: Update `application.yaml` with your Git repo URL and apply it!
