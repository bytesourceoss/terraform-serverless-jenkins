#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

output "rsa_private_key" {
  value = tls_private_key.jenkins_ec2_agents.private_key_pem
}

output "rsa_public_key" {
  value = tls_private_key.jenkins_ec2_agents.public_key_openssh
}

output "loadbalancer_url" {
  value = aws_lb.alb.dns_name
}

output "ecs_loadbalancer_url" {
  value = aws_lb.nlb.dns_name
}

output "security_group_ecs" {
  value = aws_security_group.jenkins_agent.id
}

output "security_group_ec2" {
  value = aws_security_group.jenkins_agent_ec2.id
}

output "private_subnets" {
  value = var.private_subnets
}

output "security_group_jenkins_master" {
  value = aws_security_group.jenkins_master.id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.store.id
}

output "efs_access_point_id" {
  value = aws_efs_access_point.for_ecs_jenkins.id
}
