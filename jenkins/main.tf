data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "jenkins_role" {
  name               = "jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "jenkins_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy_document" "jenkins_ci_permissions" {
  statement {
    sid    = "S3AccessForArtifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }


}

resource "aws_iam_role_policy" "jenkins_policy" {
  name   = "${var.env}-jenkins-permissions"
  role   = aws_iam_role.jenkins_role.id
  policy = data.aws_iam_policy_document.jenkins_ci_permissions.json
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.env}-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}


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

resource "aws_instance" "jenkins" {
  ami                         = aws_ami.ubuntu.id # Ubuntu, Amazon Linux, etc.
  instance_type               = "t3.micro"
  subnet_id                   = element(var.public_subnet_ids, 0)
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_instance_profile.name
  key_name                    = var.key_name
  vpc_id                      = var.vpc_id
  availability_zone           = var.aws_region

  tags = {
    Name        = "jenkins-ci"
    Environment = var.env
  }

  user_data = file("${path.module}/install_jenkins.sh") # Shell script to install Jenkins
}

