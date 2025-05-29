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

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.main.repository_url}:nginx-latest"
      cpu       = floor(var.ecs_task_cpu * 0.3)
      memory    = floor(var.ecs_task_memory * 0.3)
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}/nginx"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.project_name}-nginx"
        }
      }
    },
    {
      name      = "php-fpm"
      image     = "${aws_ecr_repository.main.repository_url}/php-fpm-latest"
      cpu       = floor(var.ecs_task_cpu * 0.7)
      memory    = floor(var.ecs_task_memory * 0.7)
      essential = true
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "APP_ENV"
          value = "production"
        },
        {
          name  = "APP_DEBUG"
          value = "false"
        },
        {
          name  = "APP_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "DB_CONNECTION"
          value = "sqlite"
        },
        {
          name      = "APP_KEY"
          valueFrom = data.aws_secretsmanager_secret.app_key.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}/php-fpm"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.project_name}-php-fpm"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task-definition"
  }
}

data "aws_secretsmanager_secret" "app_key" {
  name = "${var.project_name}-env-app-key"
}
