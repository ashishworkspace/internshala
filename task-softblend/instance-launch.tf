locals {
  vpc_id = "vpc-08d4704598b69ddd6"
  subnet_id = "subnet-0a58c683e8d64294c"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "tmp"
  public_key = trimspace(file("./ssh/tmp.pub"))
}

module "instace_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2-sg"
  description = "Allow all Traffic"
  vpc_id      = local.vpc_id

   ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "-1"
      description = "SSH from Anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [module.instace_sg.security_group_id]
  subnet_id              = local.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = "My EC2 Instance"
  }
}