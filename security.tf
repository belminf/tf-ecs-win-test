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

resource "aws_iam_role" "ecs" {
  name = "ecs-win-test-ecsrole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow", 
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ecs.amazonaws.com"
    }
  }]
} 
EOF
}

resource "aws_iam_role_policy" "ecs" {
  name = "ecs-win-test-ecspolicy"
  role = "${aws_iam_role.ecs.id}"

  policy = <<EOF
{
  "Statement": [{
    "Effect": "Allow", 
    "Action": [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer", 
      "elasticloadbalancing:DeregisterTargets", 
      "elasticloadbalancing:Describe*", 
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer", 
      "elasticloadbalancing:RegisterTargets", 
      "ec2:Describe*", 
      "ec2:AuthorizeSecurityGroupIngress"
    ], 
    "Resource": "*"
  }] 
}
EOF
}
