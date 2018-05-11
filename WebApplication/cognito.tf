# Website example
variable config_file_tpl { default = "1_StaticWebHosting/website/js/config.js.tpl"}

locals = {
  config_file = "${substr(var.config_file_tpl, 0, length(var.config_file_tpl)-4)}"
}

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

data "template_file" "config" {
  template = "${file(var.config_file_tpl)}"

  vars {
    POOL_ID = "${aws_cognito_user_pool.pool.id}"
    POOL_CLIENT_ID = "${aws_cognito_user_pool_client.client.id}"
    REGION = "${var.region}"
    APIGW_URL = "${aws_api_gateway_deployment.api_deploy.invoke_url}"
  }
}

resource "null_resource" "local" {
  triggers {
    template = "${data.template_file.config.rendered}"
  }

  provisioner "local-exec" {
    # Write file wihout .tpl extension & upload to S3 (hardcoded, due to poor support from TF)
    command = "echo \"${data.template_file.config.rendered}\" > ${local.config_file} && aws --profile personal s3 cp ${local.config_file} s3://${aws_s3_bucket.s3hosting.bucket}/js/config.js"
  }

  depends_on = ["aws_s3_bucket.s3hosting"]
}

