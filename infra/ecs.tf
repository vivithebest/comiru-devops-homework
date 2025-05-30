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
          "awslogs-create-group"  = "true"
          "awslogs-group"         = "/ecs/${var.project_name}/nginx"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.project_name}-nginx"
        }
      }
    },
    {
      name      = "php-fpm"
      image     = "${aws_ecr_repository.main.repository_url}:php-fpm-latest"
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
      ]
      secrets = [
        {
          name      = "APP_KEY"
          valueFrom = data.aws_secretsmanager_secret.app_key.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
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
  lifecycle {
    ignore_changes = [
      container_definitions,
    ]
  }
}

data "aws_secretsmanager_secret" "app_key" {
  name = "${var.project_name}-env-app-key"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-ecs-cluster"
  }
}

resource "aws_ecs_service" "app" {
  name                 = "${var.project_name}-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.app.arn
  desired_count        = var.ecs_desired_count
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [module.app_sg_80_http.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

  health_check_grace_period_seconds = 60

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name = "${var.project_name}-ecs-service"
  }
}

# ecs service auto scaling
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = var.ecs_autoscale_max_count
  min_capacity       = var.ecs_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "scale_up" {
  name               = "${var.project_name}-scale-up"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace
  schedule           = "cron(10 8 * * ? *)" # JST time 17:00
  scalable_target_action {
    min_capacity = var.ecs_autoscale_max_count
    max_capacity = var.ecs_autoscale_max_count
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_down" {
  name               = "${var.project_name}-scale-down"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace
  schedule           = "cron(59 8 * * ? *)" # JST time 17:59
  scalable_target_action {
    min_capacity = var.ecs_desired_count
    max_capacity = var.ecs_desired_count
  }
}
