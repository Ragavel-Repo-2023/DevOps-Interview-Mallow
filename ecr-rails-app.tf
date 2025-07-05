provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "rails" {
  name = "rails-app"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "rails_ecr_repository_url" {
  value = aws_ecr_repository.rails.repository_url
  description = "The URL of the ECR repository for the Rails app"
}
