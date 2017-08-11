resource "aws_security_group" "default" {
  name   = "ecs-win-test"
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Project = "ecs-win-test"
  }

  # Web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB ports
  ingress {
    from_port = "31000"
    to_port   = "61000"
    protocol  = "tcp"
    self      = true
  }

  # Internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
