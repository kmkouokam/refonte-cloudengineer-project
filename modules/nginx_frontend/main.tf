# data "aws_ssm_parameter" "ubuntu_ami" {
#   name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"]

#   filter {
#     name   = "image-id"
#     values = [data.aws_ssm_parameter.ubuntu_ami.value]
#   }
# }

# resource "aws_instance" "nginx" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   subnet_id              = var.subnet_id
#   vpc_security_group_ids = [aws_security_group.nginx_sg.id]
#   key_name               = var.key_name
#   user_data              = file("${path.module}/user_data.sh")

#   tags = merge(var.tags, {
#     Name = "${var.env}-nginx"
#   })
# }

# resource "aws_security_group" "nginx_sg" {
#   name        = "${var.env}-nginx-sg"
#   description = "Allow HTTP from ALB"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [var.alb_sg_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.tags, {
#     Name = "${var.env}-nginx-sg"
#   })
# }
