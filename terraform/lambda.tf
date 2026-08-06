locals {

  lambda_functions = [
    "createPost",
    "getPosts",
    "getPostById",
    "updatePost",
    "deletePost"
  ]

}

data "archive_file" "lambda_zip" {

  for_each = toset(local.lambda_functions)

  type = "zip"

  source_file = "${path.module}/../dist/${each.value}.js"

  output_path = "${path.module}/../dist/${each.value}.zip"

}

resource "aws_lambda_function" "posts" {

  for_each = toset(local.lambda_functions)

  function_name = "${local.name_prefix}-${each.value}"

  filename = data.archive_file.lambda_zip[each.key].output_path

  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  role = aws_iam_role.lambda_role.arn

  runtime = "nodejs24.x"

  handler = "${each.value}.handler"

  timeout = 10

  memory_size = 256

  environment {

    variables = {

      TABLE_NAME = aws_dynamodb_table.posts.name

      APP_AWS_REGION = var.aws_region

    }

  }

  tags = local.common_tags

}

resource "aws_cloudwatch_log_group" "posts" {
  for_each = toset(local.lambda_functions)

  name              = "/aws/lambda/${aws_lambda_function.posts[each.key].function_name}"
  retention_in_days = 14

  tags = local.common_tags
}