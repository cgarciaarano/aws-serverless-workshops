# Website example

## RESOURCES

# DynamoDB
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name = "Rides"

  attribute = {
    name = "RideId"
    type = "S"
  }

  hash_key = "RideId"

  read_capacity  = 5
  write_capacity = 5
}

# Lambda

# Role policy definition
data "aws_iam_policy_document" "writer_lamdba_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# S3 policy definition
data "aws_iam_policy_document" "writer_dynamo_policy-def" {
  statement {
    effect = "Allow"

    actions = [
      "ddb:PutItem",
    ]

    resources = [
      "${aws_dynamodb_table.basic-dynamodb-table.arn}",
    ]
  }
}

resource "aws_iam_policy" "writer_dynamo_policy" {
  name        = "writer_dynamo-policy"
  description = "Allow write to Dynamo"
  policy      = "${data.aws_iam_policy_document.writer_dynamo_policy-def.json}"
}

# Role definition
resource "aws_iam_role" "iam_role_for_lambda" {
  name               = "lambda_dynamo_rw"
  assume_role_policy = "${data.aws_iam_policy_document.writer_lamdba_policy.json}"
}

resource "aws_iam_role_policy_attachment" "attach_writer" {
  role       = "${aws_iam_role.iam_role_for_lambda.name}"
  policy_arn = "${aws_iam_policy.writer_dynamo_policy.arn}"
}
