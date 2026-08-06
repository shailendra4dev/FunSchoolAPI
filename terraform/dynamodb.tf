resource "aws_dynamodb_table" "posts" {

  name = "${local.name_prefix}-posts"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = true

  tags = local.common_tags

}