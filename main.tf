resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id


  tags = {
    Name = "dev-rt"
  }

}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

resource "aws_route_table_association" "mtc_public_association" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}


resource "aws_security_group" "mtc_sg" {
  name = "dev_sg"
  description = "dev security group"
  vpc_id = aws_vpc.mtc_vpc.id

# incoming network traffic
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #outgoing network traffic

  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_key_pair" "mtc_auth" {
  key_name = "mtckey"
  public_key = file("~/.ssh/mtckey.pub") #created with ssh-keygen -t ed25519
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  tags = {
    name = "dev-node"
  }

  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }

  depends_on = [
    aws_vpc.mtc_vpc,
    aws_subnet.mtc_public_subnet,
    aws_security_group.mtc_sg
  ]


  #The local-exec provisioner in Terraform allows you to run any command on your own computer,
  #separate from the resources that Terraform is managing. 
  #It's like having a way to execute commands on your local machine
  #as part of your Terr~/.ssh/mtckeyaform configuration.
  #This provisioner is useful when you need to execute tasks that are not directly related 
  #to creating or managing infrastructure resources, 
  #but are necessary for your deployment or setup process

    provisioner "local-exec" {
      command = templatefile("linux-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ec2-user",
      identityfile = "~/.ssh/mtckey"
    }) 

  }
}