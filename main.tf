variable "dynamodb_table_arn" {}
variable "dynamodb_table_stream_arn" {}
variable "dynamodb_table_name" {}
variable "backup_s3_bucket_name" {}

module "s3" {
  source      = "./s3/"
  bucket_name = "${var.backup_s3_bucket_name}"
}

module "lambda" {
  source               = "./lambda/"
  ddb_table_arn        = "${var.dynamodb_table_arn}"
  ddb_table_stream_arn = "${var.dynamodb_table_stream_arn}"
  ddb_table_name       = "${var.dynamodb_table_name}"
  bucket_name          = "${var.backup_s3_bucket_name}"
} 
