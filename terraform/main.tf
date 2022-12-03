resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "network_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

resource "aws_eip" "network_a" {
  vpc        = true
  depends_on = [aws_internet_gateway.network_a]
}

resource "aws_internet_gateway" "network_a" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "network_a" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.network_a.id
  }
}

resource "aws_route_table_association" "network_a" {
  route_table_id = aws_route_table.network_a.id
  subnet_id      = aws_subnet.network_a.id
}

resource "aws_network_interface" "iface_a" {
  subnet_id   = aws_subnet.network_a.id
  security_groups = [aws_security_group.instance_a.id]
}

resource "aws_security_group" "instance_a" {
  name   = "instance A"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["46.10.148.153/32"]
  }

    ingress {
    description = ""
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      "46.10.148.153/32",
      "192.30.252.0/22",
      "185.199.108.0/22",
      "140.82.112.0/20",
      "143.55.64.0/20",
    ]
  }

    ingress {
    description = ""
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["46.10.148.153/32"]
  }

    ingress {
    description = ""
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["46.10.148.153/32"]
  }

    ingress {
    description = ""
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["46.10.148.153/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

resource "aws_instance" "a" {
  ami           = "ami-076309742d466ad69" # eu-central-1
  instance_type = "t3.small"
  key_name      = "devopsproject"

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }
  network_interface {
    network_interface_id = aws_network_interface.iface_a.id
    device_index         = 0
  }
}

resource "aws_subnet" "network_c" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = false
}

resource "aws_nat_gateway" "network_c" {
  allocation_id = aws_eip.network_a.id
  subnet_id     = aws_subnet.network_a.id
}

resource "aws_route_table" "network_c" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.network_c.id
  }
}

resource "aws_route_table_association" "network_c" {
  route_table_id = aws_route_table.network_c.id
  subnet_id      = aws_subnet.network_c.id
}

resource "aws_network_interface" "iface_b" {
  subnet_id   = aws_subnet.network_c.id
  security_groups = [aws_security_group.instance_b.id]
}

resource "aws_security_group" "instance_b" {
  name   = "instance B"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

resource "aws_instance" "b" {
  ami           = "ami-076309742d466ad69" # eu-central-1
  instance_type = "t2.micro"
  key_name      = "devopsproject"
  

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  network_interface {
    network_interface_id = aws_network_interface.iface_b.id
    device_index         = 0
  }
}