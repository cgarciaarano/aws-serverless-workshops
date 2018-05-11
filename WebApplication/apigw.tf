resource "aws_api_gateway_rest_api" "site_api" {
  name        = "WildRydes"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name                   = "WildRydes"
  rest_api_id            = "${aws_api_gateway_rest_api.site_api.id}"
  type = "COGNITO_USER_POOLS"
  provider_arns = ["${aws_cognito_user_pool.pool.arn}"]
}

# Resources
resource "aws_api_gateway_resource" "ride" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.site_api.root_resource_id}"
  path_part   = "ride"
}

resource "aws_api_gateway_method" "post_ride" {
  rest_api_id   = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id   = "${aws_api_gateway_resource.ride.id}"
  http_method   = "POST"
  authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_authorizer.id}"
}

# Lamdba integration

resource "aws_api_gateway_integration" "lambda_ride_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id             = "${aws_api_gateway_resource.ride.id}"
  http_method             = "${aws_api_gateway_method.post_ride.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.request_unicorn_lambda.arn}/invocations"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.request_unicorn_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.site_api.id}/*/${aws_api_gateway_method.post_ride.http_method}${aws_api_gateway_resource.ride.path}"
}

# CORS shit
module "MyResourceCors" {
  source = "github.com/cgarciaarano/terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.ride.id}"
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
}

resource "aws_api_gateway_method_response" "post_ride_200" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id = "${aws_api_gateway_resource.ride.id}"
  http_method = "${aws_api_gateway_method.post_ride.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

# Deployment
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = ["aws_api_gateway_integration.lambda_ride_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  stage_name  = "prod"
}