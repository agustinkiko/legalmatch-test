variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-060e277c0d4cce553"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "ap-southeast-1"
}
