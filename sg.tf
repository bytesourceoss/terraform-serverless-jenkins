#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

# Security groups, because we like to keep network security in its own place for better overview

# Get IPs of the network loadbalancer to allow heath checks
locals {
  # The NLB dns name is tf-lb-<id>-<id>.eu-central-1....amazon.com
  # The NLB description is ELB net/tf-lb-<id>/<id>
  nlb_jenkins_agent_name = split("loadbalancer/", aws_lb.nlb.arn)[1]
}

data "aws_network_interfaces" "network_lb_inferface_ids" {
  filter {
    name   = "description"
    values = ["*${local.nlb_jenkins_agent_name}*"]
  }
}

data "aws_network_interface" "network_lb_interfaces" {
  for_each = data.aws_network_interfaces.network_lb_inferface_ids.ids
  id = each.key
}

# Allow access to ECS container instances only from the load balancer (application and network)
resource "aws_security_group" "jenkins_master" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, {Name = "Serverless Jenkins - Jenkins Master access from LoadBalancer and agents"})

  ingress {
    from_port = 8001
    to_port   = 8001
    protocol  = "tcp"

    security_groups = [aws_security_group.ecs_lb.id, aws_security_group.jenkins_agent.id]
    cidr_blocks = sort(formatlist("%s/32", [for n in data.aws_network_interface.network_lb_interfaces : n.private_ips[0]]))
  }

  ingress {
    from_port = 50000
    to_port   = 50000
    protocol  = "tcp"

    # All Jenkins agents _must_ have this security group attached
    security_groups = [aws_security_group.jenkins_agent.id]
    cidr_blocks = formatlist("%s/32", [for n in data.aws_network_interface.network_lb_interfaces : n.private_ips[0]])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This security group needs to be attached to Jenkins agents!
resource "aws_security_group" "jenkins_agent" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, {Name = "Serverless Jenkins - Jenkins ECS Agents"})

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allows access to EC2 agents from Jenkins master only
resource "aws_security_group" "jenkins_agent_ec2" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, {Name = "Serverless Jenkins - Jenkins EC2 Agents"})

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [aws_security_group.jenkins_master.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Access to Application LB from all the world
resource "aws_security_group" "ecs_lb" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, {Name = "Serverless Jenkins - Application LB Internet access"})

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Access to EFS from services only
resource "aws_security_group" "efs" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, {Name = "Serverless Jenkins - EFS access from ECS tasks"})

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = [aws_security_group.jenkins_master.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
