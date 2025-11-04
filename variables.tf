variable "aws_region" {
 description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Your public IP address for SSH access to bastion (format: x.x.x.x/32)"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "techcorp-key"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "Instance type for database server"
  type        = string
  default     = "t3.small"
}