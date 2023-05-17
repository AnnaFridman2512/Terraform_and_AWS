data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "image-id"
    values = ["ami-01acac09adf473073"]
  }
}


output "server_ami_id" {
  value = data.aws_ami.server_ami.id
}