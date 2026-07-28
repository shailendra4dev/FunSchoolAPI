locals {

  lambda_functions = [
    "createTodo",
    "getTodos",
    "getTodoById",
    "updateTodo",
    "deleteTodo"
  ]

}

resource "aws_lambda_function" "todos" {

  for_each = toset(local.lambda_functions)

  function_name = "${local.name_prefix}-${each.value}"

  filename = "${path.module}/../build/lambda.zip"

  source_code_hash = filebase64sha256("${path.module}/../build/lambda.zip")

  role = aws_iam_role.lambda_role.arn

  runtime = "nodejs24.x"

  handler = "src/handlers/${each.value}.handler"

  timeout = 10

  memory_size = 256

  environment {

    variables = {

      TABLE_NAME = aws_dynamodb_table.todos.name

      APP_AWS_REGION = var.aws_region

    }

  }

  tags = local.common_tags

}

resource "aws_cloudwatch_log_group" "todos" {
  for_each = toset(local.lambda_functions)

  name              = "/aws/lambda/${aws_lambda_function.todos[each.key].function_name}"
  retention_in_days = 14

  tags = local.common_tags
}