data "aws_caller_identity" "current" {}

# github action email iam
resource "aws_iam_user" "github_actions_ses" {
  name = "${var.project_name}-github-actions-ses"
  tags = {
    Project = var.project_name
    Purpose = "Allow GitHub Actions to send SES emails"
  }
}

resource "aws_iam_policy" "ses_send_policy" {
  name_prefix = "${var.project_name}-ses-send-policy-"
  description = "Allows sending emails via SES"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ses_send_attachment" {
  user       = aws_iam_user.github_actions_ses.name
  policy_arn = aws_iam_policy.ses_send_policy.arn
}

resource "aws_iam_access_key" "github_actions_ses" {
  user = aws_iam_user.github_actions_ses.name
}

# IAM roles for ECS tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name_prefix = "${var.project_name}-ecs-task-execution-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-execution-role"
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name_prefix = "${var.project_name}-ecs-task-execution-create-log-group-policy-"
  description = "Allows ECS task execution role to create CloudWatch Log Groups"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}/*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_create_log_group_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_role" "ecs_task_role" {
#   name_prefix = "${var.project_name}-ecs-task-role-"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     Name = "${var.project_name}-ecs-task-role"
#   }
# }

# resource "aws_iam_policy_attachment" "ecs_task_role_s3_policy" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }
