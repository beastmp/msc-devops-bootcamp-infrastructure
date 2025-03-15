# MultiCloud, DevOps & AI Challenge - Day 3 (Beginners)

# Create a GitHub Account

1. Go to [github.com](http://github.com)
2. Click "Sign up" in the top right corner
3. Enter your email
4. Create a strong password
5. Choose a unique username
6. Confirm your email through the verification code
7. Complete the personalization questions (optional)
8. Create a new repository:
    - Click the "+" button in the top right corner
    - Select "New repository"
    - Give your repository a name
    - Choose whether it will be public or private
    - Initialize with a README if desired
    - Click "Create repository"

# Exploring AWS CodePipeline in the AWS Console

1. Log in to the AWS Console at [console.aws.amazon.com](https://console.aws.amazon.com)
2. In the top search bar, type "CodePipeline" and select the service
3. On the CodePipeline homepage:
    - Observe the main panel showing your existing pipelines
    - Note the "Create pipeline" button in the top right corner
    - Explore the left sidebar to see other available options
4. Click "Create pipeline" to explore the creation wizard:
    - Examine the source code options (GitHub, CodeCommit, S3)
    - See the different build providers available
    - Explore the deployment options
5. In the existing pipelines section:
    - Observe the visual structure of pipelines
    - See the different states (Success, In Progress, Failed)
    - Explore the execution history options
6. Explore the settings:
    - Examine the notification settings
    - View the logging options
    - Explore the permission policies

# MultiCloud, DevOps & AI Challenge - Day 3 (Experienced)

## Part 1: CI/CD Pipeline Configuration

### Create a free account on GitHub and then create a new repository on GitHub called cloudmart

```docker
cd challenge-day2/frontend
<Run GitHub steps>
```

### Start by pushing the changes in the CloudMart application source code to GitHub

```
git status
git add -A
git commit -m "app sent to repo"
git push
```

### **Configure AWS CodePipeline**

1. **Create a New Pipeline:**
    - Access AWS CodePipeline.
    - Start the 'Create pipeline' process.
    - Name: **`cloudmart-cicd-pipeline`**
    - Pipeline Type: **`Queued`**
    - Source Provider: **`GitHub (version 1/OAuth)`**
    - Connect To GitHub
    - Repository: **`cloudmart-application`**
    - Branch: **`main`**
    - Change Detection: **`GitHub Webhooks`**
    - Build Provider: **`AWS CodeBuild`**
    - Region: **`US East (N. Virginia)`**
    - Input Artifacts: **`SourceArtifact`**

    - Add the 'cloudmartBuild' project as the build stage.
    - Add the 'cloudmartDeploy' project as the deployment stage.

### Configure **AWS CodeBuild to Build the Docker Image**

1. **Create a Build Project:**
    - Project name: **`cloudmartBuild`**
    - Provisioning Model: On-demand (default)
    - Environment image: managed image (default)
    - Compute: EC2 (default)
    - Operating System: Amazon Linux (default)
    - Runctime(s): Standard (default)
    - Image: amazonlinux2-x86_64-standard:4.0
    - Image Version: always use latest (default)
    - Service Role: New Service Role (default)
    - Role Name: (default)
    - Privileged: Enabled (used to support docker builds)
    - Certificate: Do not install (default)
    - Compute: 3GB mem, 2 vcpus
    - Add the environment variable **ECR_REPO** with the ECR repository URI.
    - For the build specification, use the following **`buildspec.yml`**:

```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      docker: 20
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - REPOSITORY_URI=$ECR_REPO
      - aws ecr-public get-login-password --region ${region} | docker login --username AWS --password-stdin public.ecr.aws/${registry_alias}
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - export imageTag=$CODEBUILD_RESOLVED_SOURCE_VERSION
      - printf '[{\"name\":\"cloudmart-app\",\"imageUri\":\"%s\"}]' $REPOSITORY_URI:$imageTag > imagedefinitions.json
      - cat imagedefinitions.json
      - ls -l

env:
  exported-variables: ["imageTag"]

artifacts:
  files:
    - imagedefinitions.json
    - cloudmart-frontend.yaml

```

1. **Add the AmazonElasticContainerRegistryPublicFullAccess permission to ECR in the service role**
- Access the IAM console > Roles.
- Look for the role created "cloudmartBuild" for CodeBuild.
- Add the permission **AmazonElasticContainerRegistryPublicFullAccess**

- Cloudwatch Logs: Enabled (default)

## Continue To CodePipeline

### Configure AWS CodeBuild for Application Deployment

**Create a Deployment Project:**

- Repeat the process of creating projects in CodeBuild.
- Give this project a different name (for example, **`cloudmartDeployToProduction`**).
- Configure the environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for the credentials of the user **`eks-user`** in Cloud Build, so it can authenticate to the Kubernetes cluster.

*Note: in a real-world production environment, it is recommended to use an IAM role for this purpose. In this practical exercise, we are directly using the credentials of the* **`eks-user`** *to facilitate the process, since our focus is on CI/CD and not on user authentication at this moment. The configuration of this process in EKS is more extensive. Refer to the Reference section and check "Enabling IAM principal access to your cluster"*

- For the deployment specification, use the following **`buildspec.yml`**:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 20
    commands:
      - curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
      - chmod +x ./kubectl
      - mv ./kubectl /usr/local/bin
      - kubectl version --short --client
  post_build:
    commands:
      - aws eks update-kubeconfig --region us-east-1 --name cloudmart
      - kubectl get nodes
      - ls
      - IMAGE_URI=$(jq -r '.[0].imageUri' imagedefinitions.json)
      - echo $IMAGE_URI
      - sed -i "s|CONTAINER_IMAGE|$IMAGE_URI|g" cloudmart-frontend.yaml
      - kubectl apply -f cloudmart-frontend.yaml

```

- Replace the image URI on line 18 of the **`cloudmart-frontend.yaml`** files with CONTAINER_IMAGE.
- Commit and push the changes.

```bash
git add -A
git commit -m "replaced image uri with CONTAINER_IMAGE"
git push
```

## **Part 2: Test your CI/CD Pipeline**

1. **Make a Change on GitHub:**
    - Update the application code in the **`cloudmart-application`** repository.
    - File `src/components/MainPage/index.jsx` line 93
    - Commit and push the changes.
    
    ```bash
    git add -A
    git commit -m "changed to Featured Products on CloudMart"
    git push
    ```
    
2. **Observe the Pipeline Execution:**
    - Watch how CodePipeline automatically triggers the build.
    - After the build, the deployment phase should begin.
3. **Verify the Deployment:**
    - Check Kubernetes using **`kubectl`** commands to confirm the application update.