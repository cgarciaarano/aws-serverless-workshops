# Website example

## RESOURCES

# S3 bucket
resource "aws_s3_bucket" "s3hosting" {
  bucket = "wildrydes-cgarcia"
  acl    = "public-read"

  provisioner "local-exec" {
    command = "aws --profile personal s3 sync 1_StaticWebHosting/website s3://${self.bucket}"
  }

  website {
    index_document = "index.html"
  }
}

# ## PERMISSIONS

# Role policy definition
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

# S3 policy definition
data "aws_iam_policy_document" "allow_read_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.s3hosting.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_read_policy" {
  bucket = "${aws_s3_bucket.s3hosting.id}"
  policy = "${data.aws_iam_policy_document.allow_read_policy.json}"
}

output "s3-url" {
  value = "${aws_s3_bucket.s3hosting.website_endpoint}"
}
