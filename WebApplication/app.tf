# Website example

## RESOURCES

# S3 bucket
resource "aws_s3_bucket" "s3hosting" {
  bucket = "wildrydes-cgarcia"
  acl    = "public-read"

  provisioner "local-exec" {
    command = "aws --profile personal s3 sync 1_StaticWebHosting/website s3://${self.bucket}"
  }
}

# ## PERMISSIONS

# # Role policy definition
# data "aws_iam_policy_document" "notify_lamdba_policy" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# # S3 policy definition
# data "aws_iam_policy_document" "notify_s3_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]

#     resources = [
#       "${aws_s3_bucket.upload.arn}",
#     ]
#   }
# }
