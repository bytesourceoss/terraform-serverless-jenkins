#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

# Attach this role to any ECS container or EC2 instance to allow full access to the AWS APIs and mounting of the shared EFS
data "aws_iam_policy_document" "ecs_task_jenkins" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_jenkins" {
  name               = "ServerlessJenkinsECSTaskContainerRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_jenkins.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_jenkins" {
  role       = aws_iam_role.ecs_task_jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_jenkins" {
  name = "ServerlessJenkinsEC2AndEFS"
  role = aws_iam_role.ecs_task_jenkins.name
}
