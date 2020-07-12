#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "aws_ecs_cluster" "jenkins" {
  name = "ServerlessJenkinsCluster"
  tags = var.tags
}
