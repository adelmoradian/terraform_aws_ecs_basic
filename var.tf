variable "region" {
  default = "us-east-1"
}

variable "env" {
  default = "demo"
}

variable "Subnet" {
  type = map(any)
  default = {
    "10.0.1.0/24" = 0,
    "10.0.2.0/24" = 1
  }
}

variable "image_id" {}
variable "key_name" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
