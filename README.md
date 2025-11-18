# TechCorp AWS Infrastructure - Terraform Deployment

## Overview
This project deploys a highly available web application infrastructure on AWS using Terraform. The infrastructure includes a VPC with public and private subnets across multiple availability zones, an Application Load Balancer, web servers, a database server, and a bastion host for secure administrative access.

## Architecture
- **VPC**: 10.0.0.0/16 CIDR block with DNS support enabled
- **Subnets**: 2 public subnets and 2 private subnets across 2 availability zones
- **EC2 Instances**: 
  - 1 Bastion host (t3.micro) in public subnet
  - 2 Web servers (t3.micro) in private subnets running Apache
  - 1 Database server (t3.small) in private subnet running PostgreSQL
- **Load Balancer**: Application Load Balancer distributing traffic to web servers
- **Security**: Security groups controlling access between components
- **NAT Gateways**: Providing internet access for private subnet instances

## Prerequisites
Before deploying this infrastructure, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** installed (version 1.0 or later)
   ```bash
   # Check version
   terraform version
   ```
4. **SSH Key Pair** created in AWS EC2
   - Go to EC2 Console → Key Pairs → Create Key Pair
   - Download the `.pem` file and store it securely
5. **Your Public IP Address** for bastion access
   ```bash
   curl ifconfig.me
   ```

## Project Structure
```
terraform-assessment/
├── main.tf                      
├── variables.tf                 
├── outputs.tf                   
├── terraform.tfvars.example     
├── user_data/
│   ├── web_server_setup.sh     
│   └── db_server_setup.sh      
├── evidence/                   
│   ├── terraform-plan.png
│   ├── terraform-apply.png
│   ├── aws-resources.png
│   ├── alb-web-server-1.png
│   ├── alb-web-server-2.png
│   ├── ssh-bastion.png
│   ├── ssh-web-server-1.png
│   ├── ssh-web-server-2.png
│   ├── ssh-db-server.png
│   └── postgres-connection.png
└── README.md                    
```

## Deployment Instructions

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/month-one-assessment.git
cd month-one-assessment
```

### Step 2: Configure Variables
1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   aws_region        = "us-east-1"
   key_name          = "techcorp-key"           # Your AWS key pair name
   my_ip             = "YOUR_IP_ADDRESS/32"     # Your public IP
   instance_type_web = "t3.micro"
   instance_type_db  = "t3.small"
   ```

3. Get your public IP:
   ```bash
   curl ifconfig.me
   ```

### Step 3: Initialize Terraform
```bash
terraform init
```

This will download the required AWS provider plugins.

### Step 4: Review the Deployment Plan
```bash
terraform plan
```

Review the resources that will be created. Take a screenshot of this output for your submission.

### Step 5: Deploy the Infrastructure
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

⏱️ **Expected Duration**: 5-10 minutes

Take a screenshot of the successful completion message.

### Step 6: Retrieve Outputs
```bash
terraform output
```

This will display:
- VPC ID
- Load Balancer DNS name
- Bastion public IP
- SSH commands for accessing servers

## Accessing the Infrastructure

### Access Web Application via Load Balancer
1. Get the Load Balancer DNS from outputs:
   ```bash
   terraform output alb_dns_name
   ```

2. Open in browser:
   ```
   http://<alb-dns-name>
   ```

3. Refresh multiple times to see different web servers responding

### SSH Access to Bastion Host
```bash
ssh -i /path/to/techcorp-key.pem ec2-user@<bastion-public-ip>
```

### SSH Access to Private Instances (via Bastion)

**Option 1: Jump Host (One Command)**
```bash
# Web Server 1
ssh -i /path/to/techcorp-key.pem -J ec2-user@<bastion-ip> ec2-user@<web-server-1-private-ip>

# Web Server 2
ssh -i /path/to/techcorp-key.pem -J ec2-user@<bastion-ip> ec2-user@<web-server-2-private-ip>

# Database Server
ssh -i /path/to/techcorp-key.pem -J ec2-user@<bastion-ip> ec2-user@<db-server-private-ip>
```

**Option 2: Two-Step Process**
```bash
# Step 1: SSH to Bastion
ssh -i /path/to/techcorp-key.pem ec2-user@<bastion-public-ip>

# Step 2: Copy key to bastion (from local machine)
scp -i /path/to/techcorp-key.pem /path/to/techcorp-key.pem ec2-user@<bastion-ip>:~/

# Step 3: From bastion, SSH to private instances
ssh -i ~/techcorp-key.pem ec2-user@<private-ip>
```

### Connect to PostgreSQL Database
1. SSH to database server:
   ```bash
   ssh -i ~/techcorp-key.pem ec2-user@<db-server-private-ip>
   ```

2. Connect to PostgreSQL:
   ```bash
   sudo -u postgres psql
   ```

3. Run verification commands:
   ```sql
   \l                    -- List databases
   \c techcorp_db        -- Connect to database
   SELECT * FROM server_info;
   \conninfo             -- Show connection info
   \q                    -- Quit
   ```

## Verification Checklist

- [ ] VPC and subnets created in AWS Console
- [ ] 4 EC2 instances running (1 bastion, 2 web, 1 db)
- [ ] Load balancer distributing traffic to both web servers
- [ ] Web application accessible via ALB DNS
- [ ] Both web servers showing different instance IDs
- [ ] SSH access to bastion from local machine
- [ ] SSH access to web servers via bastion
- [ ] SSH access to database server via bastion
- [ ] PostgreSQL running and accessible on database server
- [ ] All security groups properly configured

## Troubleshooting

### Issue: Cannot SSH to Bastion
**Solution**: 
- Verify your IP address hasn't changed: `curl ifconfig.me`
- Update security group or re-run `terraform apply` with new IP

### Issue: Cannot Access Load Balancer
**Solution**:
- Wait 2-3 minutes for instances to pass health checks
- Check target group health in AWS Console
- Verify security groups allow HTTP traffic

### Issue: Web Servers Not Responding
**Solution**:
- SSH to web server and check Apache status:
  ```bash
  sudo systemctl status httpd
  ```
- Check user data execution logs:
  ```bash
  sudo cat /var/log/cloud-init-output.log
  ```

### Issue: PostgreSQL Not Installed
**Solution**:
- Manually install on DB server:
  ```bash
  sudo yum install -y postgresql-server
  sudo /usr/bin/postgresql-setup --initdb
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
  ```

## Cleanup Instructions

### Destroy All Resources
```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

⚠️ **Warning**: This will permanently delete all resources. Ensure you have:
- Saved all necessary data
- Taken required screenshots
- Exported terraform state file

### Verify Cleanup
1. Check AWS Console to ensure all resources are deleted
2. Verify no lingering resources that might incur costs:
   - EC2 instances
   - Load balancers
   - NAT gateways
   - Elastic IPs

## Security Best Practices

1. **Never commit sensitive data**:
   - Don't commit `terraform.tfvars` with real values
   - Don't commit `.pem` key files
   - Don't commit `terraform.tfstate` with sensitive data

2. **Restrict SSH access**:
   - Only allow your IP to access bastion
   - Use SSH keys, not passwords when possible
   - Regularly rotate credentials

3. **Network isolation**:
   - Web and DB servers are in private subnets
   - Only bastion host is publicly accessible
   - Security groups follow principle of least privilege

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)



## Author
**Your Name**  
Christiana Shedrack

