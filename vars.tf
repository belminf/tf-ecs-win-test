variable "desired_capacity" {
  type        = "string"
  description = "ASG desired capacity"
}

variable "min_size" {
  type        = "string"
  default     = 1
  description = "ASG min size"
}

variable "max_size" {
  type        = "string"
  description = "ASG max size"
}

variable "key_name" {
  type        = "string"
  description = "Key pair name"
}

variable "region" {
  type        = "string"
  default     = "us-east-1"
  description = "AWS region"
}

variable "az1" {
  type        = "string"
  default     = "us-east-1a"
  description = "AZ for subnet 1"
}

variable "az2" {
  type        = "string"
  default     = "us-east-1b"
  description = "AZ for subnet 2"
}

variable "instance_type" {
  type        = "string"
  description = "AWS instance type"
}

# us-east1 ami: Windows_Server-2016-English-Full-Containers-2017.07.13
variable "ami" {
  type        = "string"
  default     = "ami-25ece233"
  description = "AMI for Windows"
}
