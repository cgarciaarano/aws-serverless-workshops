# Website example

## RESOURCES

# Lambda definition
resource "aws_lambda_function" "list_rides_lambda" {
  function_name = "ListUnicornRides"
  filename         = "${data.archive_file.lambda_rides_code.output_path}"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file(data.archive_file.lambda_rides_code.output_path))}"
  runtime          = "nodejs6.10"
  handler          = "listUnicornRides.handler"
}

data "archive_file" "lambda_rides_code" {
  type        = "zip"
  source_file = "5_OAuth/listUnicornRides.js"
  output_path = "dist/listUnicornRides.zip"
}


# Lambda authorizer
resource "aws_lambda_function" "authorizer_lambda" {
  function_name = "Authorizer"
  filename         = "${data.local_file.lambda_auth_code.filename}"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file(data.local_file.lambda_auth_code.filename))}"
  runtime          = "nodejs6.10"
  handler          = "index.handler"

  environment {
    variables = {
      USER_POOL_ID = "${aws_cognito_user_pool.pool.id}"
    }
  }
}

data "local_file" "lambda_auth_code" {
  filename = "5_OAuth/ListUnicornAuthorizer.zip"
}
