resource "aws_ecs_cluster" "default" {
  name = "ecs-win-test-cluster"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "ecs-win-test-log"
  retention_in_days = 3

  tags = {
    Project = "ecs-win-test"
  }
}

resource "aws_ecs_task_definition" "default" {
  family = "ecs-win-test-tasks"

  container_definitions = <<EOF
[{
    "name": "ecs-win-test",
    "cpu": 100,
    "essential": true,
    "image": "microsoft/iis",
    "memory": 500,
    "portMappings" : [{"ContainerPort": 80}],
    "entryPoint": ["powershell"],
    "command": ["New-Item -Path C:\\inetpub\\wwwroot\\index.html -Type file -Value '<html><head><title>Hello world!</title><body>You see me? Nice!; C:\\ServiceMonitor.exe w3svc"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.default.name}",
        "awslogs-stream-prefix": "ecs-win-test-stream",
        "awslogs-region": "${var.region}"
      }
    }
}]
EOF
}

resource "aws_ecs_service" "default" {
  name            = "ecs-win-test"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.default.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs.arn}"

  depends_on = [
    "aws_iam_role.ecs",
    "aws_alb_listener.default",
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    container_name   = "ecs-win-test"
    container_port   = 80
  }
}
