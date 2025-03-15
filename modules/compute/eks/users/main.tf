# modules/compute/eks/users/main.tf
# Create IAM user
resource "aws_iam_user" "user" {
  name          = var.username
  force_destroy = var.force_destroy
  
  tags = merge(
    var.common_tags,
    {
      Name    = var.username
      IsAdmin = contains(var.groups, var.admin_group_name) ? "true" : "false"
    }
  )
}

# Direct policy attachment for admin user
resource "aws_iam_user_policy_attachment" "admin_policy" {
  count = contains(var.groups, var.admin_group_name) ? 1 : 0
  
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create access key for programmatic access
resource "aws_iam_access_key" "user_key" {
  count = var.programmatic_access ? 1 : 0
  
  user = aws_iam_user.user.name
}

# Create login profile for console access
resource "aws_iam_user_login_profile" "user_console" {
  count = var.console_access ? 1 : 0
  
  user                    = aws_iam_user.user.name
  password_reset_required = true
  pgp_key                 = "keybase:terraform"
}

# Create AWS Secrets Manager entry to store user credentials
resource "aws_secretsmanager_secret" "user_credentials" {
  name                    = var.secret_name
  description             = "Credentials for user ${var.username}"
  recovery_window_in_days = 0
  
  tags = merge(
    var.common_tags,
    {
      Name = var.secret_name
      User = var.username
    }
  )
}

# Store user credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "user_credentials" {
  secret_id = aws_secretsmanager_secret.user_credentials.id
  
  secret_string = jsonencode({
    username = aws_iam_user.user.name
    access_key_id = var.programmatic_access ? aws_iam_access_key.user_key[0].id : null
    secret_access_key = var.programmatic_access ? aws_iam_access_key.user_key[0].secret : null
    password_encrypted = var.console_access ? aws_iam_user_login_profile.user_console[0].encrypted_password : null
    password_reset_required = var.console_access
    console_access = var.console_access
    programmatic_access = var.programmatic_access
    admin_user = contains(var.groups, var.admin_group_name)
    created_at = timestamp()
  })
}