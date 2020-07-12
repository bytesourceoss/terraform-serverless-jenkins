#
# Copyright (C) 2020 ByteSource Technology Consulting GmbH
#
# All rights reserved - Do Not Redistribute
#

variable "tags" {
  description = "Tags applied to each resource"
  type        = map
  default     = {}
}

variable "public_subnets" {
  description = "List of subnets used for the application lb"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of subnets used for the internal network lb"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy to"
  type        = string
}
