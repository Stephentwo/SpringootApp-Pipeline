
# Import the AWS provider
provider "aws" {
    region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "springbootvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "springbootvpc"
    }
}

# Create a subnet
resource "aws_subnet" "springbootsubnet" {
    vpc_id     = aws_vpc.springbootvpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "springbootsubnet"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "springbootigw" {
    vpc_id = aws_vpc.springbootvpc.id
    tags = {
        Name = "springbootigw"
    }
}

# Create a route table
resource "aws_route_table" "springbootroute" {
    vpc_id = aws_vpc.springbootvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.springbootigw.id
    }
    tags = {
        Name = "springbootroute-table"
    }
}

# Create a route table association
resource "aws_route_table_association" "springbootroutetableasso" {
    subnet_id      = aws_subnet.springbootsubnet.id
    route_table_id = aws_route_table.springbootroute.id
}

# Create a security group
resource "aws_security_group" "springbootsg" {
    name        = "springbootsg-security-group"
    description = "springbootsg security group"
    vpc_id      = aws_vpc.springbootvpc.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "springboot-asg" {
    name                 = "springboot-asg"
    min_size             = 1
    max_size             = 1
    desired_capacity     = 1
    vpc_zone_identifier  = [aws_subnet.springbootsubnet.id]
    launch_configuration = aws_launch_configuration.springbootlaunchconfig.name
}

# Create a Launch Configuration
resource "aws_launch_configuration" "springbootlaunchconfig" {
    name                 = "springbootlaunchconfig-lc"
    image_id             = "ami-0ff8a91507f77f867"
    instance_type        = "t2.micro"
    security_groups      = [aws_security_group.springbootsg.id]
    associate_public_ip_address = true
} 

# Create an EC2 instance
resource "aws_instance" "springboot-ec2" {
    ami           = "ami-0ff8a91507f77f867"
    instance_type = "t2.micro"
    key_name = "ec2keypair"
    user_data = <<-EOF
                    #!/bin/bash
                    yum update -y
                    yum install docker -y
                    service docker start
                    docker pull chuksteve/spring-boot-react-app:latest
                    docker run -d -p 80:80 chuksteve/spring-boot-react-app:latest
                    EOF
    subnet_id     = aws_subnet.springbootsubnet.id
    associate_public_ip_address = true
    security_groups = [aws_security_group.springbootsg.id]
    tags = {
        Name = "springboot-ec2"
    }
}