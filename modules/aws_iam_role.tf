resource "aws_iam_role" "ppm_ecs" {
  assume_role_policy = <<-JSON
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": ["ecs.amazonaws.com","ecs-tasks.amazonaws.com"]
        }
      }
    ]
  }
  JSON

  name = "${var.resource_base_name}_ecs"
}

resource "aws_iam_role" "ppm_execution" {
  assume_role_policy = <<-JSON
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
        }
      }
    ]
  }
  JSON

  name = "${var.resource_base_name}_execution"
}

resource "aws_iam_role_policy_attachment" "ppm_ecs_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = "${aws_iam_role.ppm_ecs.id}"
}
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = "${aws_iam_role.ppm_ecs.id}"
}
