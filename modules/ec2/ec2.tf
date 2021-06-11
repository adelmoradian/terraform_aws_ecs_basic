variable "env" {}
variable "image_id" {}
variable "key_name" {}
variable "sg_ids" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
variable "subnet_ids" {}


resource "random_id" "id" {
  byte_length = 2
}

resource "aws_ecs_cluster" "demo" {
  name = var.env
}

resource "aws_launch_configuration" "demo" {
  name                        = "${var.env}-ec2-launch-config-${random_id.id.hex}"
  image_id                    = var.image_id
  key_name                    = var.key_name
  security_groups             = [var.sg_ids]
  instance_type               = var.instance_type
  enable_monitoring           = true
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true
  user_data                   = templatefile("./user_data.tpl", { CLUSTER_NAME = aws_ecs_cluster.demo.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  depends_on                = [aws_launch_configuration.demo]
  name                      = "${var.env}-asg"
  vpc_zone_identifier       = var.subnet_ids
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  default_cooldown          = 600
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.demo.name
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = var.env
    propagate_at_launch = true
  }
}
