# modules/compute/ec2/iam/main.tf
# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = var.service_principal
      }
    }]
  })
  
  tags = merge(
    var.common_tags,
    {
      Name = var.role_name
    }
  )
}

# Create instance profile for the role
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.ec2_role.name
}