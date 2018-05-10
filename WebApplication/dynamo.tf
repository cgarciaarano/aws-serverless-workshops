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

  read_capacity  = 1
  write_capacity = 1
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
      "dynamodb:PutItem",
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
  name               = "WildRydesLambda"
  assume_role_policy = "${data.aws_iam_policy_document.writer_lamdba_policy.json}"
}

resource "aws_iam_role_policy_attachment" "attach_writer" {
  role       = "${aws_iam_role.iam_role_for_lambda.name}"
  policy_arn = "${aws_iam_policy.writer_dynamo_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_basic_lambda" {
  role       = "${aws_iam_role.iam_role_for_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda definition
resource "aws_lambda_function" "request_unicorn_lambda" {
  function_name = "RequestUnicorn"
  filename         = "${data.archive_file.lambda_code.output_path}"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file(data.archive_file.lambda_code.output_path))}"
  runtime          = "nodejs6.10"
  handler          = "requestUnicorn.handler"
  
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "3_ServerlessBackend/requestUnicorn.js"
  output_path = "dist/requestUnicorn.zip"
}
