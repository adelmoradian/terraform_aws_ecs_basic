variable "env" {}
variable "Subnet" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "demo" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.env
  }
}
resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = var.env
  }
}

resource "aws_subnet" "demo" {
  for_each          = var.Subnet
  availability_zone = data.aws_availability_zones.available.names[each.value]
  vpc_id            = aws_vpc.demo.id
  cidr_block        = each.key

  tags = {
    Name = var.env
  }
}

data "aws_subnet_ids" "demo" {
  vpc_id     = aws_vpc.demo.id
  depends_on = [aws_subnet.demo]
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all-${var.env}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.demo.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.env
  }
}

resource "aws_route_table_association" "a" {
  count          = length(var.Subnet)
  depends_on     = [data.aws_subnet_ids.demo]
  subnet_id      = tolist(data.aws_subnet_ids.demo.ids)[count.index]
  route_table_id = aws_vpc.demo.main_route_table_id
}

resource "aws_route" "r" {
  route_table_id         = aws_vpc.demo.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo.id
}

output "sg_ids" {
  value = aws_security_group.allow_all.id
}
output "subnet_ids" {
  value = data.aws_subnet_ids.demo.ids
}
