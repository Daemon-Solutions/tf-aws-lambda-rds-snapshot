variable "name" {}

variable "envname" {}

variable "cron_start_schedule" {
  default = "cron(0 7 * * ? *)"
}

variable "service" {
  default = "rds-snapshot"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "db_id" {}

variable "db_instance_name" {}

variable "delete_snapshot_older_than" {}
