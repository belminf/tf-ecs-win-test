resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name    = "ecs-win-test"
    Project = "ecs-win-test"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name    = "ecs-win-test"
    Project = "ecs-win-test"
  }
}

resource "aws_route" "default" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ecs-win-test-sn1"
    Project = "ecs-win-test"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ecs-win-test-sn2"
    Project = "ecs-win-test"
  }
}


