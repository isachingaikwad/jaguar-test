data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# # Internet VPC
# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   instance_tenancy     = "default"
#   enable_dns_support   = "true"
#   enable_dns_hostnames = "true"
#   enable_classiclink   = "false"
#   tags = {
#     Name = "main"
#   }
# }

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_configuration" "test_jaguar" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.amazon-linux.id
  instance_type   = var.instance_type
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.test_jaguar_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test_jaguar" {
  name                 = "test_jaguar"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.test_jaguar.name
  vpc_zone_identifier  = module.vpc.public_subnets

  tag {
    key                 = "Name"
    value               = "HashiCorp ASG - test_jaguar"
    propagate_at_launch = true
  }
}

resource "aws_lb" "test_jaguar" {
  name               = "asg-test-jaguar-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_jaguar_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "test_jaguar" {
  load_balancer_arn = aws_lb.test_jaguar.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_jaguar.arn
  }
}

resource "aws_lb_target_group" "test_jaguar" {
  name     = "asg-test-jaguar"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


resource "aws_autoscaling_attachment" "test_jaguar" {
  autoscaling_group_name = aws_autoscaling_group.test_jaguar.id
  alb_target_group_arn   = aws_lb_target_group.test_jaguar.arn
}

resource "aws_security_group" "test_jaguar_instance" {
  name = "learn-asg-test-jaguar-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.test_jaguar_lb.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.test_jaguar_lb.id]
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "test_jaguar_lb" {
  name = "learn-asg-test-jaguar-lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}
