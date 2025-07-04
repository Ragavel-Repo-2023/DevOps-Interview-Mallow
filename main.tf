terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "vpc" {
  source  = "./vpc.tf"
}

module "eks" {
  source  = "./eks.tf"
}

module "rds" {
  source = "./rds.tf"
}

module "s3" {
  source = "./s3.tf"
}

module "iam" {
  source = "./iam.tf"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "irsa_s3_role_arn" {
  value = aws_iam_role.irsa_s3.arn
}
