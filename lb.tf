#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "aws_lb" "alb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_lb.id]
  subnets            = var.public_subnets

  tags = merge(var.tags, { Name = "Serverless Jenkins LoadBalancer" })
}

resource "aws_lb_target_group" "jenkins" {
  port        = 8001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  # Give Jenkins enough time to start and especially to restart after plugin updates
  health_check {
    interval            = 120
    timeout             = 20
    healthy_threshold   = 5
    unhealthy_threshold = 5

    path     = "/login"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}
