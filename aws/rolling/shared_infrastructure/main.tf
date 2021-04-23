resource "aws_ecr_repository" "main" {
  name                 = var.name_of_ecr_image
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "null_resource" "push_to_ecr" {
  triggers = {
    image_change = var.docker_hub_image_to_push
  }

  provisioner "local-exec" {
    command = "copyImageToECR.sh"
    environment = {
      region         = var.region
      ecrRepoURL         = aws_ecr_repository.main.repository_url
      dockerHubImage = var.docker_hub_image_to_push      
    }
  }
}

resource "aws_ecr_lifecycle_policy" "policies" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
