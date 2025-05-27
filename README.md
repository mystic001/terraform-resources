# Azure Terraform Resources

This repository contains Terraform configurations for deploying Azure resources.

## Directory Structure

```
.
├── environments/           # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/               # Reusable Terraform modules
│   ├── network/
│   ├── compute/
│   └── storage/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Variable definitions
├── outputs.tf           # Output definitions
├── terraform.tfvars     # Variable values (gitignored)
└── .gitignore          # Git ignore file
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0.0)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription

## Getting Started

1. Install the prerequisites
2. Login to Azure:
   ```bash
   az login
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the planned changes:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values
2. Modify the variables in `terraform.tfvars` according to your needs
3. Run Terraform commands as needed

## Modules

- `network`: Network-related resources (VNet, Subnets, etc.)
- `compute`: Compute resources (VMs, VMSS, etc.)
- `storage`: Storage resources (Storage Accounts, etc.)

## Contributing

1. Create a new branch for your changes
2. Make your changes
3. Submit a pull request

## License

MIT

## GitHub Actions Setup

### Required Secrets

Set up the following secrets in your GitHub repository (Settings > Secrets and variables > Actions):

1. `AZURE_CLIENT_ID`: Azure service principal client ID
2. `AZURE_CLIENT_SECRET`: Azure service principal client secret
3. `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
4. `AZURE_TENANT_ID`: Azure tenant ID

### Creating Azure Service Principal

1. Install Azure CLI
2. Login to Azure:
   ```bash
   az login
   ```
3. Create service principal with necessary permissions:
   ```bash
   # Create the service principal
   az ad sp create-for-rbac --name "terraform-github-actions" \
                           --role "Key Vault Administrator" \
                           --scopes /subscriptions/<subscription_id> \
                           --sdk-auth
   ```
4. Copy the output and use it to set up the secrets in GitHub

### Required Azure Permissions

The service principal needs the following permissions:
- Key Vault Administrator role
- Contributor role on the subscription (for resource creation)
- Access to Key Vault secrets

### Troubleshooting Key Vault Access

If you encounter Key Vault access issues:

1. Verify the service principal has the correct role:
   ```bash
   az role assignment list --assignee <service-principal-id>
   ```

2. Check Key Vault access policies:
   ```bash
   az keyvault show --name <key-vault-name> --query properties.accessPolicies
   ```

3. If needed, manually add access policy:
   ```bash
   az keyvault set-policy --name <key-vault-name> \
                         --object-id <service-principal-id> \
                         --secret-permissions get list set delete backup restore recover purge
   ```

## Environment Protection Rules

1. Go to repository Settings > Environments
2. Create a new environment named 'production'
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Branch protection rules

## Workflow Features

- Runs on PR to main branch
- Runs on push to main branch
- Performs Terraform format check
- Validates Terraform configuration
- Creates plan for PR review
- Applies changes when merged to main
- Comments plan results on PR 
