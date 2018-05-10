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
