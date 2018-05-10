# Website example

## RESOURCES

# Cognito user pool
resource "aws_cognito_user_pool" "pool" {
  name = "wildrydes"

  auto_verified_attributes = ["email"]

  schema = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = "false"
      mutable                  = "true"
      name                     = "email"
      required                 = "true"

      string_attribute_constraints {
        max_length = 2048
        min_length = 0
      }
    },
  ]
}


resource "aws_cognito_user_pool_client" "client" {
  name = "client"

  user_pool_id = "${aws_cognito_user_pool.pool.id}"

}

data "template_file" "init" {
  template = "${file("1_StaticWebHosting/website/js/config.js.tpl")}"

  vars {
    POOL_ID = "${aws_cognito_user_pool.pool.id}"
    POOL_CLIENT_ID = "${aws_cognito_user_pool_client.client.id}"
    REGION = "${var.region}"
  }
}