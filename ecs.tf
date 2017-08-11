resource "aws_ecs_cluster" "cluster" {
  name = "ecs-win-test-cluster"
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "ecs-win-test-log"
  retention_in_days = 3

  tags = {
    Project = "ecs-win-test"
  }
}

resource "aws_ecs_task_definition" "taskdef" {
  family = "ecs-win-test-tasks"

  container_definitions = <<EOF
[{
    "name": "ecs-win-test",
    "cpu": 100,
    "essential": true,
    "image": "microsoft/iis",
    "memory": 500,
    "entryPoint": ["powershell"],
    "command": ["New-Item -Path C:\\inetpub\\wwwroot\\index.html -Type file -Value '<html><head><title>Hello world!</title><body>You see me? Nice!; C:\\ServiceMonitor.exe w3svc"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.loggroup.name}",
        "awslogs-stream-prefix": "ecs-win-test-stream",
        "awslogs-region": "${var.region}"
      }
    }
}]
EOF
}
