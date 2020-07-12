#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "aws_lb" "nlb" {
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnets

  tags = merge(var.tags, { Name = "Serverless Jenkins LoadBalancer" })
}

resource "aws_lb_target_group" "jenkins_agent_jnlp" {
  port        = 50000
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  # Give Jenkins enough time to start and especially to restart after plugin updates
  health_check {
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 10
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "jenkins_agent_jnlp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "50000"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_agent_jnlp.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "jenkins_agent_http" {
  port        = 8001
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  # Give Jenkins enough time to start and especially to restart after plugin updates
  health_check {
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 10
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "jenkins_agent_http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "8001"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_agent_http.arn
    type             = "forward"
  }
}
