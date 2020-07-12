#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

resource "tls_private_key" "jenkins_ec2_agents" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "aws_key_pair" "jenkins_agents_autogen" {
  key_name   = "jenkins_agents_autogen"
  public_key = tls_private_key.jenkins_ec2_agents.public_key_openssh
}
