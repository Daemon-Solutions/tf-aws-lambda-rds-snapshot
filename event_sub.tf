resource "aws_db_event_subscription" "db_subscription" {
  name        = "rds-snapshot-events"
  sns_topic   = "${aws_sns_topic.db_snapshot_topic.arn}"
  source_type = "db-instance"
  source_ids  = ["${var.db_id}"]

  event_categories = [
    "backup",
  ]
}

resource "aws_sns_topic" "db_snapshot_topic" {
  name         = "db-snapshot-creation"
  display_name = "db-snapshot-creation"
}

resource "aws_sns_topic_subscription" "db_snapshot_topic" {
  topic_arn              = "${aws_sns_topic.db_snapshot_topic.arn}"
  protocol               = "lambda"
  endpoint               = "${aws_lambda_function.rds_snapshot_cleanup.arn}"
  endpoint_auto_confirms = true
}
