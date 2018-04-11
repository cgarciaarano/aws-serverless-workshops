# Website example

## RESOURCES

# Cognito user pool
resource "aws_cognito_user_pool" "pool" {
  name = "wildrydes"

  auto_verified_attributes = ["email"]

  schema = [
    {
      attribute_data_type = "String"
      developer_only_attribute = "false"
      mutable = "true"
      name = "email"
      required = "true"
      string_attribute_constraints {
        max_length = 2048
        min_length = 0
      }
    }
  ]
}
