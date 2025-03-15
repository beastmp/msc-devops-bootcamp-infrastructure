# modules/compute/ec2/main.tf
module "iam" {
  source = "./iam"
  
  role_name                = var.instance_role_name
  service_principal        = var.service_principal
  
  common_tags = merge(
    var.common_tags,
    {
      Name             = var.name
      "Component Role" = var.component_role
      Platform         = var.platform
    }
  )
}

resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_public_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

# Create EC2 instance based on variables
resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_public_key.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  availability_zone      = var.availability_zone
  iam_instance_profile   = module.iam.instance_profile_name
  
  user_data = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    tags        = merge(var.common_tags, { Name = var.root_volume_name })
  }

  tags = merge(
    var.common_tags,
    {
      Name             = var.name
      "Component Role" = var.component_role
      Platform         = var.platform
    }
  )
}

# Creates and stores ssh key secret used creating an EC2 instance
resource "aws_secretsmanager_secret" "ssh_key" {
  name                    = var.secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ssh_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.ssh_key.id
  secret_string = tls_private_key.ssh_private_key.private_key_pem
}