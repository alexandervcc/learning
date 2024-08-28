provider "aws" {
  region = "us-east-2"  # Replace with your AWS region
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${var.environment}-service"
  cluster         = "arn:aws:ecs:us-east-2:905418244733:cluster/ecs-basics-cluster"
  task_definition = var.task_definition
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}