provider "aws" {
  region = var.region
}

resource "aws_key_pair" "redis_key_pair" {
  key_name   = "redis-key-pair"
  public_key = var.public_key
}

resource "aws_subnet" "redis_subnet" {
  vpc_id                  = "vpc-0b448e60"
  cidr_block              = "172.31.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "redis-subnet"
  }
}

resource "aws_instance" "redis_server" {
  ami                         = "ami-00bb6a80f01f03502"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.redis_sg.id]
  key_name                    = aws_key_pair.redis_key_pair.key_name
  subnet_id                   = aws_subnet.redis_subnet.id
  
  tags = {
    Name = "redis-server"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "Security group for Redis server"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.redis_server.public_ip
} 