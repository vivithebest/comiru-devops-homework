variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "A unique name for the project, used as a prefix for resources."
  type        = string
  default     = "devops-homework"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "v2comiru.click"
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory in MiB for the ECS task"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired count for the ECS service"
  type        = number
  default     = 2
}
