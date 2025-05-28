resource "aws_ecr_repository" "main" {
  name = "${var.project_name}-registry"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.project_name}-registry"
  }
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.main.repository_url
}
