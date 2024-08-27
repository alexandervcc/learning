variable "environment" {
  description = "Environment name (e.g., production, qa)"
  type        = string
}

variable "task_definition" {
  description = "Full ARN of the task definition including the version"
  type        = string
}

variable "desired_count" {
  description = "Number of desired tasks"
  type        = number
}

variable "subnets" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ECS service"
  type        = string
}
