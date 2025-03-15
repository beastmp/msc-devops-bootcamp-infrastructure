# MultiCloud, DevOps & AI Challenge - Day 5 (Beginner)

# **Google Cloud BigQuery Setup**

Follow these steps to set up Google Cloud BigQuery for CloudMart:

1. Create a Google Cloud Project:
    - Go to the Google Cloud Console (https://console.cloud.google.com/).
    - Click on the project dropdown and select "New Project".
    - Name the project "CloudMart" and create it.
2. Enable BigQuery API:
    - In the Google Cloud Console, go to "APIs & Services" > "Dashboard".
    - Click "+ ENABLE APIS AND SERVICES".
    - Search for "BigQuery API" and enable it.
3. Create a BigQuery Dataset:
    - In the Google Cloud Console, go to "BigQuery".
    - In the Explorer pane, click on your project name.
    - Click "CREATE DATASET".
    - Set the Dataset ID to "cloudmart".
    - Choose your data location and click "CREATE DATASET".
4. Create a BigQuery Table:
    - In the dataset you just created, click "CREATE TABLE".
    - Set the Table name to "cloudmart-orders".
    - Define the schema according to your order structure. For example:
        - id: STRING
        - items: JSON
        - userEmail: STRING
        - total: FLOAT
        - status: STRING
        - createdAt: TIMESTAMP
    - Click "CREATE TABLE".

# MultiCloud, DevOps & AI Challenge - Day 5 (Experienced)

# Download Updated Frontend and Backend Code

Backup the existing folders

```yaml
cp -R challenge-day2/ challenge-day2_bkp
cp -R terraform-project/ terraform-project_bkp
```

Clean up the existing application files expect the Docker, YAML file (Backend)

```bash
cd challenge-day2/backend
rm -rf $(find . -mindepth 1 -maxdepth 1 -not \( -name ".*" -o -name Dockerfile -o -name "*.yaml" \))
```

Clean up the existing application files expect the Docker, YAML file (Frontend)

```bash
cd challenge-day2/frontend
rm -rf $(find . -mindepth 1 -maxdepth 1 -not \( -name ".*" -o -name Dockerfile -o -name "*.yaml" \))
```

Download the updated source code and unzip it (Backend)

```yaml
cd challenge-day2/backend
wget  https://tcb-public-events.s3.amazonaws.com/mdac/resources/final/cloudmart-backend-final.zip
unzip cloudmart-backend-final.zip

```

Download the updated source code and unzip it (Frontend)

```yaml
cd challenge-day2/frontend
wget  https://tcb-public-events.s3.amazonaws.com/mdac/resources/final/cloudmart-frontend-final.zip
unzip cloudmart-frontend-final.zip
git add -A
git commit -m "final code"
git push 

```

# **Google Cloud BigQuery Setup**

Follow these steps to set up Google Cloud BigQuery for CloudMart:

1. Create a Google Cloud Project:
    - Go to the Google Cloud Console (https://console.cloud.google.com/).
    - Click on the project dropdown and select "New Project".
    - Name the project "CloudMart" and create it.
2. Enable BigQuery API:
    - In the Google Cloud Console, go to "APIs & Services" > "Dashboard".
    - Click "+ ENABLE APIS AND SERVICES".
    - Search for "BigQuery API" and enable it.
3. Create a BigQuery Dataset:
    - In the Google Cloud Console, go to "BigQuery".
    - In the Explorer pane, click on your project name.
    - Click "CREATE DATASET".
    - Set the Dataset ID to "cloudmart".
    - Choose your data location and click "CREATE DATASET".
4. Create a BigQuery Table:
    - In the dataset you just created, click "CREATE TABLE".
    - Set the Table name to "cloudmart-orders".
    - Define the schema according to your order structure. For example:
        - id: STRING
        - items: JSON
        - userEmail: STRING
        - total: FLOAT
        - status: STRING
        - createdAt: TIMESTAMP
    - Click "CREATE TABLE".
5. Create Service Account and Key:
    - In the Google Cloud Console, go to "IAM & Admin" > "Service Accounts".
    - Click "CREATE SERVICE ACCOUNT".
    - Name it "cloudmart-bigquery-sa" and grant it the "BigQuery Data Editor" role.
    - After creating, click on the service account, go to the "Keys" tab, and click "ADD KEY" > "Create new key".
    - Choose JSON as the key type and create.
    - Save the downloaded JSON file as `google_credentials.json`.
6. Configure Lambda Function:
    - Navigate to the root directory of your project.
    - Enter the Lambda function directory:
        
        ```
        cd challenge-day2/backend/src/lambda/addToBigQuery
        
        ```
        
    - Install the required dependencies:
        
        ```
        sudo yum install npm
        npm install
        
        ```
        
    - Edit the `google_credentials.json` file in this directory and place the content of your key.
    - Create a zip file of the entire directory:
        
        ```
        zip -r dynamodb_to_bigquery.zip .
        
        ```
        
    - This zip file will be used when creating or updating the Lambda function.
    - Return to the root directory of your project:
        
        ```
        cd ../../..
        
        ```
        
7. Update Lambda Function Environment Variables:

Remember to never commit the `google_credentials.json` file to version control. It should be added to your `.gitignore` file.

# Terraform Steps

Remove the [`main.tf`](http://main.tf) file and create an empty one

```bash
rm main.tf
nano main.tf
```

Add these terraform lines to the end of [`main.tf`](http://main.tf) file to create the Lambda for the BigQuery insert. Update the values in red first.

```bash
provider "aws" {
  region = "us-east-1" 
}

# Tables DynamoDB
resource "aws_dynamodb_table" "cloudmart_products" {
  name           = "cloudmart-products"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "cloudmart_orders" {
  name           = "cloudmart-orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

resource "aws_dynamodb_table" "cloudmart_tickets" {
  name           = "cloudmart-tickets"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "cloudmart_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda function
resource "aws_iam_role_policy" "lambda_policy" {
  name = "cloudmart_lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_dynamodb_table.cloudmart_products.arn,
          aws_dynamodb_table.cloudmart_orders.arn,
          "${aws_dynamodb_table.cloudmart_orders.arn}/stream/*",
          aws_dynamodb_table.cloudmart_tickets.arn,
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

# Lambda function for listing products
resource "aws_lambda_function" "list_products" {
  filename         = "list_products.zip"
  function_name    = "cloudmart-list-products"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256("list_products.zip")

  environment {
    variables = {
      PRODUCTS_TABLE = aws_dynamodb_table.cloudmart_products.name
    }
  }
}

# Lambda permission for Bedrock
resource "aws_lambda_permission" "allow_bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "bedrock.amazonaws.com"
}

# Output the ARN of the Lambda function
output "list_products_function_arn" {
  value = aws_lambda_function.list_products.arn
}

# Lambda function for DynamoDB to BigQuery
resource "aws_lambda_function" "dynamodb_to_bigquery" {
  filename         = "../challenge-day2/backend/src/lambda/addToBigQuery/dynamodb_to_bigquery.zip"
  function_name    = "cloudmart-dynamodb-to-bigquery"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256("../challenge-day2/backend/src/lambda/addToBigQuery/dynamodb_to_bigquery.zip")

  environment {
    variables = {
      GOOGLE_CLOUD_PROJECT_ID        = "lustrous-bounty-436219-f1"
      BIGQUERY_DATASET_ID            = "cloudmart"
      BIGQUERY_TABLE_ID              = "cloudmart-orders"
      GOOGLE_APPLICATION_CREDENTIALS = "/var/task/google_credentials.json"
    }
  }
}

# Lambda event source mapping for DynamoDB stream
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.cloudmart_orders.stream_arn
  function_name     = aws_lambda_function.dynamodb_to_bigquery.arn
  starting_position = "LATEST"
}

```

Execute `terraform apply` now

# **Azure Text Analytics Setup**

Follow these steps to set up Azure Text Analytics for sentiment analysis:

1. Create an Azure Account:
    - Go to the Azure portal (https://portal.azure.com/).
    - Sign in or create a new account if you don't have one.
2. Create a Resource:
    - In the Azure portal, click "Create a resource".
    - Search for "Text Analytics" and select it.
    - Click "Create".
3. Configure the Resource:
    - Choose your subscription and resource group (create a new one if needed).
    - Name the resource (e.g., "cloudmart-text-analytics").
    - Choose your region and pricing tier.
    - Click "Review + create", then "Create".
4. Get the Endpoint and Key:
    - Once the resource is created, go to its overview page.
    - In the left menu, under "Resource Management", click "Keys and Endpoint".
    - Copy the endpoint URL and one of the keys.

# Deploy the changes on Backend

Open the file `cloudmart-backend.yaml`:

```bash
nano cloudmart-backend.yaml

```

Content of `cloudmart-backend.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudmart-backend-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudmart-backend-app
  template:
    metadata:
      labels:
        app: cloudmart-backend-app
    spec:
      serviceAccountName: cloudmart-pod-execution-role
      containers:
      - name: cloudmart-backend-app
        image: public.ecr.aws/l4c0j8h9/cloudmaster-backend:latest
        env:
        - name: PORT
          value: "5000"
        - name: AWS_REGION
          value: "us-east-1"
        - name: BEDROCK_AGENT_ID
          value: "xxxx"
        - name: BEDROCK_AGENT_ALIAS_ID
          value: "xxxx"
        - name: OPENAI_API_KEY
          value: "xxxx"
        - name: OPENAI_ASSISTANT_ID
          value: "xxxx"
        - name: AZURE_ENDPOINT
          value: "xxxx"
        - name: AZURE_API_KEY
          value: "xxxx"
        
---

apiVersion: v1
kind: Service
metadata:
  name: cloudmart-backend-app-service
spec:
  type: LoadBalancer
  selector:
    app: cloudmart-backend-app
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
```

Build a new image

```yaml
<Follow ECR steps>
```

## Update the deployment on Kubernetes

```json
kubectl apply -f cloudmart-backend.yaml
```