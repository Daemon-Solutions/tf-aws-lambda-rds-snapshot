## create lambda package
data "archive_file" "create_lambda_package_cleanup" {
  type        = "zip"
  source_dir  = "${path.module}/cleanup"
  output_path = ".terraform/cleanup.zip"
}

resource "aws_lambda_function" "rds_snapshot_cleanup" {
  filename         = ".terraform/cleanup.zip"
  source_code_hash = "${data.archive_file.create_lambda_package_cleanup.output_base64sha256}"
  function_name    = "${var.name}-${var.envname}-cleanup-snapshots"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "cleanup.lambda_handler"
  runtime          = "python2.7"
  timeout          = "300"

  environment {
    variables = {
      DBInstanceIdentifier = "${var.db_instance_name}"
      DBSnapshotIdentifier = "${var.db_instance_name}"
      Days                 = "${var.delete_snapshot_older_than}"
    }
  }
}

resource "aws_lambda_permission" "allow_sns_to_call_rds_snapshot" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_snapshot_cleanup.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.db_snapshot_topic.arn}"
}
