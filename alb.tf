resource "aws_alb" "default" {
  name            = "ecs-win-test-alb"
  internal        = false
  security_groups = ["${aws_security_group.default.id}"]
  subnets         = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
  idle_timeout    = 30

  tags = {
    Project = "ecs-win-test"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "ecs-win-test-tg"
  vpc_id   = "${aws_vpc.default.id}"
  port     = 80
  protocol = "HTTP"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
  }

  tags = {
    Project = "ecs-win-test"
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = "${aws_alb.default.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "default" {
  listener_arn = "${aws_alb_listener.default.arn}"
  priority     = 1

  action {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/"]
  }
}
