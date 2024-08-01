include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/modules/ec2"
}

inputs = {
  instance_type = "t2.micro"
  ami           = "ami-060e277c0d4cce553" 
  key_name      = "staging-key"
  aws_profile   = "legalmatch"
  aws_region    = "ap-southeast-1"
}
