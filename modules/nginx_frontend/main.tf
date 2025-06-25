data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_ami.value]
  }
}






resource "aws_launch_template" "nginx" {
  name_prefix   = "${var.env}-nginx-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.forntend_instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = var.nginx_security_group_ids


  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
sudo apt install -y amazon-cloudwatch-agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-linux -s 
EOF
  )
}

resource "aws_lb" "nginx_alb" {
  name               = "${var.env}-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.elb_security_group_ids
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.env}-nginx-alb"
  }
}

resource "aws_autoscaling_group" "nginx_asg" {
  desired_capacity    = var.desired_capacity # must be >= 1
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.nginx.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.nginx_tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.env}-nginx-asg"
    propagate_at_launch = true
  }
}
resource "aws_lb_target_group" "nginx_tg" {
  name     = "${var.env}-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
