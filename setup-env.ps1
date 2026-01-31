# PowerShell script to set up environment variables for Terraform
# Usage: .\setup-env.ps1

Write-Host "Setting up Azure environment variables for Terraform..." -ForegroundColor Cyan

# Check if .env file exists
if (Test-Path ".env") {
    Write-Host "Loading variables from .env file..." -ForegroundColor Green
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
            Write-Host "  Set $key" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "No .env file found. Using Azure CLI default subscription..." -ForegroundColor Yellow
    
    # Try to get subscription ID from Azure CLI
    try {
        $subscriptionId = az account show --query id -o tsv 2>$null
        if ($subscriptionId) {
            $env:ARM_SUBSCRIPTION_ID = $subscriptionId
            Write-Host "  Set ARM_SUBSCRIPTION_ID from Azure CLI: $subscriptionId" -ForegroundColor Green
        } else {
            Write-Host "  Warning: Could not get subscription ID from Azure CLI" -ForegroundColor Yellow
            Write-Host "  Please set ARM_SUBSCRIPTION_ID manually or create a .env file" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Error: Azure CLI not found or not logged in" -ForegroundColor Red
        Write-Host "  Please run: az login" -ForegroundColor Yellow
    }
}

Write-Host "`nEnvironment setup complete!" -ForegroundColor Green
Write-Host "You can now run Terraform commands." -ForegroundColor Green

