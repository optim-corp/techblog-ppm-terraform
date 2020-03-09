
#
# ECS cluster
#
resource "aws_ecs_cluster" "ppm" {
  name = "${var.resource_base_name}"
}

#
# ECS Service
#

# nginx server
resource "aws_ecs_service" "ppm_server" {
  cluster                            = "${aws_ecs_cluster.ppm.id}"
  deployment_minimum_healthy_percent = 50
  desired_count                      = 1
  launch_type                        = "FARGATE"
  name                               = "${var.resource_base_name}_server"

  load_balancer {
    container_name   = "${var.resource_base_name}_server"
    container_port   = "80"
    target_group_arn = "${aws_lb_target_group.ppm_server.arn}"
  }

  network_configuration {
    subnets = [
      "${aws_subnet.ppm_private_a.id}"
    ]

    security_groups = [
      "${aws_security_group.ppm_server.id}",
    ]

    assign_public_ip = false
  }

  task_definition = "${aws_ecs_task_definition.ppm_server.arn}"

}


#
# ECS Security Group
#

# nginx server
resource "aws_security_group" "ppm_server" {
  name   = "${var.resource_base_name}_server"
  vpc_id = "${aws_vpc.ppm.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.ppm_lb.id}"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.resource_base_name}_server"
  }
}


#
# ECS Task Definition
#

# nginx server
resource "aws_ecs_task_definition" "ppm_server" {
  family                   = "${var.resource_base_name}_server"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn = "${aws_iam_role.ppm_ecs.arn}"
  execution_role_arn = "${aws_iam_role.ppm_ecs.arn}"


  # "image": -> ECR にPushしたイメージURLを記入
  # "environment.name":"APP_KEY"  -> envファイルに記載されている APP_KEY を記入

  container_definitions = <<-JSON
  [
    {
      "image": "", 
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc",
      "name": "${var.resource_base_name}_server",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.resource_base_name}_server",
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "${var.resource_base_name}_nginx"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
            "name": "APP_NAME",
            "value": "Laravel"
        },
        {
            "name": "APP_KEY",
            "value": "base64:"
        },
        {
            "name": "APP_DEBUG",
            "value": "false"
        },
        {
          "name": "APP_ENV",
          "value": "production"
        },
        {
            "name": "APP_URL",
            "value": "https://"
        }
      ]
    }
  ]
  JSON
}

resource "aws_cloudwatch_log_group" "server" {
  name = "${var.resource_base_name}_server"

  tags = {
    Environment = "production"
    Application = "${aws_ecs_cluster.ppm.name}"
  }
}