terraform {
  backend "s3" {
    bucket         = ""
    key            = "external-health-check/health-check.tfstate"
    region         = "eu-central-1"
    dynamodb_table = ""
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }

  }
}

locals {
  tags = {
    author         = "anquach"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "otel_collector_and_services" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = "<>" ##Add your SSH Key pair here
  iam_instance_profile   = aws_iam_instance_profile.service_iam_profile.name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = "subnet-<>"

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }

  tags = merge({
    Name = "external-health-check"
  }, local.tags)

  user_data = file("${path.module}/ssm-agent-installer.sh")
}

####IAM ROLE For SSM Agent
resource "aws_iam_instance_profile" "service_iam_profile" {
  name = "pi.health_check_service"
  role = aws_iam_role.service_iam_role.name
}

resource "aws_iam_role" "service_iam_role" {
  name               = "ri.health_check_service"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "resources_ssm_policy" {
  role       = aws_iam_role.service_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "resources_ssm_s3_policy" {
  role       = aws_iam_role.service_iam_role.name
  policy_arn = "arn:aws:iam::<>:policy/pi.s3.fullacccess-gvd-monitoring"
}

resource "aws_security_group" "allow_web" {
  name        = "external-healcheck-server"
  description = "Allows access to Web Port"
  vpc_id      = "vpc-<>"

  #allow http

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["<>"] ###Example 0.0.0.0/32
  }

  # allow https

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["<>"] ##EDIT
  }

    # allow healcheck port

  ingress {
    from_port   = 13133
    to_port     = 13133
    protocol    = "tcp"
    cidr_blocks = ["<>"] ##EDIT
  }

  # allow SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<>"] ##EDIT
  }

  #all outbound

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
