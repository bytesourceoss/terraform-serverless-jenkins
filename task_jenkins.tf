#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "aws_ecs_task_definition" "jenkins" {
  family                = "jenkins"
  container_definitions = file("${path.module}/task-definitions/jenkins.json")
  task_role_arn         = aws_iam_role.ecs_task_jenkins.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory = 1024 # 1 GB of RAM
  cpu    = 512 # 1 CPU

  volume {
    name = "jenkins-home"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.store.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.for_ecs_jenkins.id
        iam = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "jenkins" {
  name             = "jenkins"
  cluster          = aws_ecs_cluster.jenkins.id
  launch_type      = "FARGATE"
  task_definition  = aws_ecs_task_definition.jenkins.arn
  platform_version = "1.4.0" # LATEST does not yet support EFS, check https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
  desired_count    = 1

  depends_on = [
    aws_lb_listener.jenkins_agent_jnlp,
    aws_lb_target_group.jenkins_agent_http,
    aws_lb_listener.front_end,
    aws_lb_target_group.jenkins
  ]

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.jenkins_master.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins.arn
    container_name   = "jenkins"
    container_port   = 8001
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_agent_jnlp.arn
    container_name   = "jenkins"
    container_port   = 50000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_agent_http.arn
    container_name   = "jenkins"
    container_port   = 8001
  }
}
