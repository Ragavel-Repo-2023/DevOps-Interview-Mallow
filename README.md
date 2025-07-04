Rails + Nginx on AWS EKS (with CI/CD, ALB Ingress, and IRSA)

This project deploys a Rails application behind Nginx on AWS EKS, using AWS ALB Ingress for external traffic, IRSA for secure AWS access, and GitHub Actions for CI/CD.

 Prerequisites

 AWS CLI & credentials
 Terraform
 kubectl
 Docker
 AWS ECR repositories for Rails and Nginx images
 [AWS Load Balancer Controller](https://kubernetessigs.github.io/awsloadbalancercontroller/latest/) installed on EKS



Setup & Deployment

1. Build & Push Docker Images

Build and push both Rails and Nginx images to ECR:

Authenticate to ECR
aws ecr getloginpassword region <region> | docker login username AWS passwordstdin <accountid>.dkr.ecr.<region>.amazonaws.com

Rails
docker build f Dockerfile.rails t <ECR_RAILS_URL>:latest .
docker push <ECR_RAILS_URL>:latest

Nginx
docker build f Dockerfile.nginx t <ECR_NGINX_URL>:latest .
docker push <ECR_NGINX_URL>:latest


2. Provision AWS Resources with Terraform

cd infrastructure
terraform init
terraform apply

 Creates VPC, EKS, RDS, S3, IRSA IAM roles, etc.
 Outputs important values for the next steps.


3. Update Kubernetes Manifests

 Set image URIs in deployment.yaml
 Fill in RDS, S3, and other secret values in secret.yaml
 Add the IAM role ARN (from Terraform output) in serviceaccount.yaml
 Leave LB_ENDPOINT blank initially


4. Configure kubectl

aws eks region us-east-1 updatekubeconfig name rails_app-eks-cluster


5. Deploy Kubernetes Resources

Apply manifests in this order:

kubectl apply f k8s/secret.yaml
kubectl apply f k8s/serviceaccount.yaml
kubectl apply f k8s/deployment.yaml
kubectl apply f k8s/service.yaml
kubectl apply f k8s/ingress.yaml


6. Update Secrets with ALB Endpoint

 Wait for the ALB to be provisioned (kubectl get ingress)
 Update LB_ENDPOINT in secret.yaml
 Reapply: kubectl apply f k8s/secret.yaml
 Restart deployment if needed: kubectl rollout restart deployment <name>


CI/CD with GitHub Actions

 Push to main branch triggers workflow:
  Build & push Docker images to ECR (Rails & Nginx)
  Deploy updated images to EKS


IRSA (IAM Roles for Service Accounts)

 Kubernetes service account annotated with eks.amazonaws.com/rolearn
 Terraform sets up trust policy for K8s OIDC provider and service account
 No AWS credentials in pods, Uses temporary credentials securely
