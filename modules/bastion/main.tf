<<<<<<< HEAD

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


resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  associate_public_ip_address = true

  # iam_instance_profile = var.ec2_instance_profile
  # depends_on           = [aws_security_group.bastion]


  # Example: use secrets in user_data
  user_data = <<-EOF
              #!/bin/bash
               yum install -y aws-cli jq
              SECRET=$(aws secretsmanager get-secret-value --secret-id mysql-db-credentials --region ${var.aws_region} --query SecretString --output text)
              echo "Retrieved Secret: $SECRET" >> /tmp/secret.log
              EOF

  tags = merge(var.tags, {
    Name = "${var.env}-bastion"
  })
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.env}-bastion-sg"
  description = "Allow SSH access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.env}-bastion-sg"
  })
}
=======
 
>>>>>>> 81b28f79e2a8cba6471480cefc760c93bd289f38
