variable "bucket_name" {}

resource "aws_s3_bucket" "backup_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "backup_bucket_policy" {
  bucket = "${aws_s3_bucket.backup_bucket.id}"
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PreventBucketDelete",
    "Statement": [
        {
            "Sid": "PreventDelete",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "s3:DeleteBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.backup_bucket.arn}",
                "${aws_s3_bucket.backup_bucket.arn}/*"
            ]
        }
    ]
}
POLICY
}

output "s3_arn" {
 value = "${aws_s3_bucket.backup_bucket.arn}"
}
