provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "legalmatch-instance"
  }
}


