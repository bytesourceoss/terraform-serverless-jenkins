++bytesource logo++

# terraform-serverless-jenkins

Terraform module to showcase running Jenkins serverlessly on AWS Fargate.

Disclaimer: This module is not intended for production use. Data and connections are not encrypted, and the IAM role used for the Jenkins master provides full Administrative access. If you want to run a setup like this in production reach out to us at ++link to quiz here++

## Usage

```
module "serverless_jenkins" {
  source = <todo, upload to terraform registry>

  public_subnets = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
  private_subnets = ["subnet-ccccccccccccccccc", "subnet-ddddddddddddddddd"]
  vpc_id = "vpc-aaaaaaaaaaaaaaaaa"

  tags = {
    Environment = "dev"
    Project     = "Serverless Jenkins"
  }
}

output instructions {
  value = <<EOT
Access the Jenkins master via http://${module.serverless_jenkins.loadbalancer_url}.
The first startup will take a few minutes. To configure the ECS and EC2 Plugins you need the following:

RSA Private Key: ${module.serverless_jenkins.rsa_private_key}
RSA Public Key: ${module.serverless_jenkins.rsa_public_key}

SecurityGroup for EC2 agents: ${module.serverless_jenkins.security_group_ec2}
SecurityGroup for ECS agents: ${module.serverless_jenkins.security_group_ecs}
Alternative Jenkins URL for ECS Plugin: http://${mdoule.serverless_jenkins.ecs_loadbalancer_url}:8001
Subnets for EC2 and ECS: ${join(", ", module.serverless_jenkins.private_subnets)}

To mount the EFS once create and read the initial admin key createn an EC2 instance with these:
  Security Group: ${module.serverless_jenkins.security_group_jenkins_master}
  IAM Instance profile: ServerlessJenkinsECSTaskContainerRole
Mount the FS with: mount -t efs -o tls,iam,accesspoint=${module.serverless_jenkins.efs_access_point_id} ${module.serverless_jenkins.efs_file_system_id}: /tmp/efs
EOT
}
```

Due to the nature of Terraform and our high security standards this module has to be planned and appied in two steps.

```bash
# First the network loadbalancer
terraform plan -out=tf.plan -target module.serverless_jenkins.aws_lb.nlb
terraform apply tf.plan

# Then the rest
terraform plan -out=tf.plan
terraform apply tf.plan
```

Once everything is running you can try to access the ApplicationLoadBalancer URL and it should show you a screen asking for an initial administrative password. To get this password create a temporary EC2 instance with the security group and IAM instance profile from the output of terraform and mount the EFS share. You will probalby first need to install the efs helper package via yum. Once you have the initial password you can destroy the instance.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|vpc_id|VPC ID|sring|null|yes|
|public_subnets|List of public subnets used for accessing Jenkins|list(sring)|null|yes|
|private_subnets|List of private subnets used for internal resources|list(sring)|null|yes|
|tags|Tags applied to each resource|map|{}|no|

## Outputs

| Name | Description |
|------|-------------|
|loadbalancer_url|URL of the application loadbalancer used to access Jenkins|
|rsa_private_key|RSA private key required for the Jenkins EC2 plugin|
|rsa_public_key|RSA public key|
|security_group_ec2|Security group to be attached to Jenkins EC2 agents|
|security_group_ecs|Security group to be attached to Jenkins ECS agents|
|private_subnets|The private_subnets input|
|security_group_jenkins_master|The security group attached to the Jenkins master|
|efs_file_system_id|EFS ID of the Jenkins master storage|
|efs_access_point_id|EFS access point id of the Jenkins master storage|

## Help

If you have any questions or want to run Jenkins on Fargate in production mode please reach out to use via +++ TODO +++.

##Copyright

Copyright © 2020 [ByteSource Technology Consulting GmbH](https://bytesource.net/)

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
