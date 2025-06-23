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
