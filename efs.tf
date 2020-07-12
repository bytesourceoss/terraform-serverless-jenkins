#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "aws_efs_file_system" "store" {
  tags = merge(var.tags, {Name = "Serverless Jenkins data store"})
}

resource "aws_efs_mount_target" "store" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.store.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "for_ecs_jenkins" {
  file_system_id = aws_efs_file_system.store.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/jenkins-home"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0750"
    }
  }
}

resource "aws_efs_file_system_policy" "jenkins" {
  file_system_id = aws_efs_file_system.store.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ECSJenkinsEFSPolicy",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.ecs_task_jenkins.arn}"
            },
            "Resource": "${aws_efs_file_system.store.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                },
                "StringEquals": {
                    "elasticfilesystem:AccessPointArn":"${aws_efs_access_point.for_ecs_jenkins.arn}"
                }
            }
        }
    ]
}
POLICY
}
