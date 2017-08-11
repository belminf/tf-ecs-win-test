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

resource "aws_iam_role" "ec2" {
  name = "ecs-win-test-ec2role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow", 
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    }
  }]
} 
EOF
}

resource "aws_iam_role_policy" "ec2" {
  name = "ecs-win-test-ec2policy"
  role = "${aws_iam_role.ec2.id}"

  policy = <<EOF
{
  "Statement": [{
    "Effect": "Allow", 
    "Action": [
      "ecs:CreateCluster", 
      "ecs:DeregisterContainerInstance", 
      "ecs:DiscoverPollEndpoint", 
      "ecs:Poll", 
      "ecs:RegisterContainerInstance", 
      "ecs:StartTelemetrySession", 
      "ecs:Submit*", 
      "logs:CreateLogStream", 
      "logs:PutLogEvents"
    ], 
    "Resource": "*"
  }] 
}
EOF
}

resource "aws_iam_role" "asg" {
  name = "ecs-win-test-asgrole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow", 
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "application-autoscaling.amazonaws.com"
    }
  }]
} 
EOF
}

resource "aws_iam_role_policy" "asg" {
  name = "ecs-win-test-asgpolicy"
  role = "${aws_iam_role.asg.id}"

  policy = <<EOF
{
  "Statement": [{
    "Effect": "Allow", 
    "Action": [
      "application-autoscaling:*",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "ecs:DescribeServices", 
      "ecs:UpdateService"
    ], 
    "Resource": "*"
  }] 
}
EOF
}
