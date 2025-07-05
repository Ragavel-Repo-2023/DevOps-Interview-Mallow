resource "aws_ecr_repository" "nginx" {
  name = "nginx-app"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "nginx_ecr_repository_url" {
  value       = aws_ecr_repository.nginx.repository_url
  description = "The URL of the ECR repository for the Nginx app"
}
