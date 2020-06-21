resource "aws_ecs_task_definition" "nginx" {
  family                = "nginx"
#  container_definitions = file("task-definitions/nginx.json")
  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:1.13-alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "memory": 128,
    "cpu": 100
  }
]
EOF
}
