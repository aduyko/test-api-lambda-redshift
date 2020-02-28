resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_app_name}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_app_name}"
  }
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.tag_app_name}"
  }
}

resource "aws_subnet" "redshift" {
  for_each          = var.vpc_subnets_redshift

  # subnets are in the format {"availability_zone" = "cidr_block"}
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_app_name}_redshift_${each.key}"
  }
}

resource "aws_redshift_subnet_group" "redshift_subnets" {
  name       = var.redshift_subnet_group_name
  subnet_ids = [for subnet in aws_subnet.redshift : subnet.id]

  tags = {
    Name = "${var.tag_app_name}"
  }
}

resource "aws_subnet" "lambda" {
  for_each          = var.vpc_subnets_lambda

  # subnets are in the format {"availability_zone" = "cidr_block"}
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_app_name}_lambda_${each.key}"
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.tag_app_name}_lambda"
  description = "Lambda traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redshift" {
  name        = "${var.tag_app_name}_redshift"
  description = "Redshift inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = var.redshift_port
    to_port         = var.redshift_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    # Office IP
    # cidr_blocks     = []
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
