# Terraform AWS EC2 Example

This project creates an Ubuntu EC2 instance in the AWS `us-west-2` region using
Terraform. The configuration also creates:

- An AWS key pair named `terra-key-ec2`
- A default VPC reference
- A security group that allows SSH (port 22), HTTP (port 80), and all outbound traffic
- A `t3.micro` EC2 instance with a 15 GB `gp3` root volume

## Prerequisites

You need:

- An AWS account
- An IAM user or role with permission to create EC2, security group, VPC, and key-pair resources
- Terraform CLI
- AWS CLI
- An SSH key pair whose public key is named `terra-key-ec2.pub`

The commands below use PowerShell on Windows.

## 1. Install Terraform

Install Terraform using one of the following methods:

### Windows Package Manager

```powershell
winget install Hashicorp.Terraform
```

### Chocolatey

```powershell
choco install terraform
```

Verify the installation:

```powershell
terraform version
```

## 2. Install and configure the AWS CLI

Install the AWS CLI from the
[official AWS installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
Then verify it:

```powershell
aws --version
```

## 3. Create and configure an AWS user

For local development, create an IAM user in the AWS Console and grant only the
permissions required for this example. Avoid using the AWS root account.

Create an access key for the IAM user, then configure the AWS CLI:

```powershell
aws configure
```

Enter the following values when prompted:

```text
AWS Access Key ID:     <your-access-key-id>
AWS Secret Access Key: <your-secret-access-key>
Default region name:   us-west-2
Default output format: json
```

Do not put access keys in `.tf` files, `README.md`, or source control.
Terraform uses the AWS CLI credential profile by default.

## 4. Prepare the EC2 SSH key pair

The Terraform configuration reads the public key from
`terra-key-ec2.pub`. If you do not already have this key pair, create it with
OpenSSH:

```powershell
ssh-keygen -t ed25519 -f .\terra-key-ec2
```

When prompted for a passphrase, use one if possible. This creates:

- `terra-key-ec2` - the private key used to connect to the instance
- `terra-key-ec2.pub` - the public key uploaded to AWS by Terraform

Keep the private key secure and never commit it. On Windows, restrict access to
the private key if needed

## 5. Initialize Terraform

Open PowerShell in this project directory:

```powershell
Set-Location "C:\Users\<your-user>\path\to\Terraform"
```

Initialize Terraform and download the AWS provider:

```powershell
terraform init
```

Check the configuration formatting and syntax:

```powershell
terraform fmt
terraform validate
```

## 6. Review and create the EC2 instance

Create an execution plan before making changes:

```powershell
terraform plan
```

If the plan is correct, create the security group, key pair, and EC2 instance
in the default VPC:

```powershell
terraform apply
```

Type `yes` when Terraform asks for confirmation.

The current configuration uses the AMI ID `ami-02167eae61967e403`. AMI IDs are
region-specific and can become unavailable, so replace this value in
[`ec2.tf`](./ec2.tf) with a valid Ubuntu AMI for `us-west-2` if the apply fails.
The AWS CLI can help find recent Ubuntu images, or you can select one from the
EC2 console.

## 7. Connect to the instance

Find the public IP address in the AWS EC2 console. Then connect with:

```powershell
ssh -i .\terra-key-ec2 ubuntu@<public-ip-address>
```

For a different Ubuntu image, confirm the correct default username. Common
examples are `ubuntu` for Ubuntu and `ec2-user` for Amazon Linux.

## Security notes

- The current security group allows SSH and HTTP from `0.0.0.0/0`. For a real
  deployment, restrict SSH to your public IP address, for example
  `<your-ip>/32`.
- The private key, AWS access keys, and Terraform state files can contain
  sensitive information. Do not commit them to a public repository.
- Use a remote, encrypted Terraform state backend and state locking for
  shared or production use.
- Consider using an IAM role with temporary credentials instead of long-lived
  access keys.

## Destroy the resources

When finished, remove the resources created by this project to avoid ongoing
AWS charges:

```powershell
terraform destroy
```

Type `yes` when Terraform asks for confirmation. Keep the local key files only
if you plan to reuse them; destroying the Terraform resources does not delete
the local private key.

## Project files

| File | Purpose |
| --- | --- |
| [`terraform.tf`](./terraform.tf) | Pins the required AWS provider version |
| [`providers.tf`](./providers.tf) | Configures the AWS provider and region |
| [`ec2.tf`](./ec2.tf) | Defines the key pair, VPC reference, security group, and EC2 instance |
| `terra-key-ec2.pub` | Public SSH key read by Terraform |
