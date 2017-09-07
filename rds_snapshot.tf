## create lambda package
data "archive_file" "create_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/snapshot"
  output_path = ".terraform/rds-snapshot.zip"
}

resource "aws_cloudwatch_event_rule" "take_snapshot" {
  name                = "${var.name}-${var.envname}-rds-snapshot"
  description         = "create rds snapshot"
  schedule_expression = "${var.cron_start_schedule}"
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-${var.envname}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]

}
EOF
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.name}-${var.envname}-lambda-rds"
  path        = "/"
  description = "lambda access to rds and cloudwatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "rds:AddTagsToResource",
        "rds:DeleteDBSnapshot",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSnapshots",
        "rds:ListTagsForResource",
        "rds:CreateDBSnapshot"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_rds_access" {
  name       = "${var.name}-${var.envname}-allow-access-to-rds"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.lambda.arn}"
}

resource "aws_lambda_function" "rds_snapshot" {
  filename         = ".terraform/rds-snapshot.zip"
  source_code_hash = "${data.archive_file.create_lambda_package.output_base64sha256}"
  function_name    = "${var.name}-${var.envname}-rds-snapshot"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "rds-snapshot.lambda_handler"
  runtime          = "python2.7"
  timeout          = "300"

  environment {
    variables = {
      DBInstanceIdentifier = "${var.db_instance_name}"
      DBSnapshotIdentifier = "${var.db_instance_name}"
    }
  }
}

resource "aws_cloudwatch_event_target" "take_snapshot" {
  rule = "${aws_cloudwatch_event_rule.take_snapshot.name}"
  arn  = "${aws_lambda_function.rds_snapshot.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_rds_snapshot" {
  statement_id  = "AllowExecutionFromCloudWatchstart"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_snapshot.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.take_snapshot.arn}"
}
