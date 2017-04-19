variable "bucket_name" {}
variable "ddb_table_arn" {}
variable "ddb_table_stream_arn" {}
variable "ddb_table_name" {}

resource "aws_lambda_function" "backup_ddb_table" {
  filename         = "${path.module}/backup_ddb_table_lambda.zip"
  function_name    = "${var.ddb_table_name}-backup-to-${var.bucket_name}"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "backup_ddb_table.lambda_handler"
  timeout          = "30"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${path.module}/backup_ddb_table_lambda.zip"))}"

  environment {
    variables = {
      ddb_table_name    = "${var.ddb_table_name}"
      ddb_backup_bucket = "${var.bucket_name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "backup_ddb_table" {
  event_source_arn  = "${var.ddb_table_stream_arn}"
  function_name     = "${aws_lambda_function.backup_ddb_table.arn}"
  starting_position = "LATEST"
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.ddb_table_name}-backup-to-${var.bucket_name}"
  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy" "allow_log_creation" {
  name   = "${var.ddb_table_name}-backup-to-${var.bucket_name}"
  role   = "${aws_iam_role.lambda_role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }, 
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }, 
    {
      "Action": [
        "dynamodb:Scan"
      ],
      "Effect": "Allow",
      "Resource": ["${var.ddb_table_arn}", "${var.ddb_table_stream_arn}"]
    }
  ]
}
POLICY
}

output "lambda_arn" {
  value = "${aws_lambda_function.backup_ddb_table.arn}"
}
