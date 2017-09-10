variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
    default = "ap-northeast-1"
}
variable "aws_zone" {
    default = "ap-northeast-1c"
}
variable "allow_arn" {}
variable "allow_ip" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "es1"
  elasticsearch_version = "5.5"
  cluster_config {
    instance_type = "m4.large.elasticsearch"
  }

  ebs_options {
    "ebs_enabled" = "true"
    "volume_type" = "SSD"
    "volume_size" = "10"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": { "AWS": ["${var.allow_arn}"] },
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["${var.allow_ip}"]}
            }
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "esDomain"
  }
}
