resource "aws_lb" "ppm" {
  name = "${var.resource_base_name}"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = true

  subnets = [
    "${aws_subnet.ppm_public_a.id}",
    "${aws_subnet.ppm_public_c.id}"
  ]

  security_groups = [
    "${aws_security_group.ppm_lb.id}",
  ]
}
resource "aws_security_group" "ppm_lb" {
  name   = "${var.resource_base_name}_lb"
  vpc_id = "${aws_vpc.ppm.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.resource_base_name}_lb"
  }
}

resource "aws_lb_listener" "ppm_redirect" {
  load_balancer_arn = "${aws_lb.ppm.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "ppm_server" {
  load_balancer_arn = "${aws_lb.ppm.arn}"
  port              = "443"
  protocol          = "HTTPS"
  
  # 登録した証明書のARN
  certificate_arn = "" 
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.ppm_server.id}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ppm_server" {
  deregistration_delay = 10

  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 5
  }

  name     = "${var.resource_base_name}-server"
  port     = 80
  protocol = "HTTP"

  target_type = "ip"

  stickiness {
    type = "lb_cookie"
  }

  vpc_id = "${aws_vpc.ppm.id}"
}