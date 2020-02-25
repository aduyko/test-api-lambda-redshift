resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
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
    Name = "${var.tag_app_name}_${each.key}"
  }
}

resource "aws_redshift_subnet_group" "redshift-subnets" {
  name       = var.redshift_subnet_group_name
  subnet_ids = [for subnet in aws_subnet.redshift : subnet.id]

  tags = {
    environment = "Production"
  }
}
