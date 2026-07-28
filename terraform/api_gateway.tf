resource "aws_api_gateway_rest_api" "todo_api" {

  name = "${local.name_prefix}-api"

  description = "Todo CRUD API"

  endpoint_configuration {

    types = ["REGIONAL"]

  }

  tags = local.common_tags

}

resource "aws_api_gateway_resource" "todos" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  parent_id = aws_api_gateway_rest_api.todo_api.root_resource_id

  path_part = "todos"

}

resource "aws_api_gateway_resource" "todo_id" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  parent_id = aws_api_gateway_resource.todos.id

  path_part = "{id}"

}

locals {

  api_methods = {

    createTodo = {

      resource = aws_api_gateway_resource.todos.id

      method = "POST"

    }

    getTodos = {

      resource = aws_api_gateway_resource.todos.id

      method = "GET"

    }

    getTodoById = {

      resource = aws_api_gateway_resource.todo_id.id

      method = "GET"

    }

    updateTodo = {

      resource = aws_api_gateway_resource.todo_id.id

      method = "PUT"

    }

    deleteTodo = {

      resource = aws_api_gateway_resource.todo_id.id

      method = "DELETE"

    }

  }

}

resource "aws_api_gateway_method" "todos" {

  for_each = local.api_methods

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  resource_id = each.value.resource

  http_method = each.value.method

  authorization = "NONE"

}

resource "aws_api_gateway_integration" "todos" {

  for_each = local.api_methods

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  resource_id = each.value.resource

  http_method = aws_api_gateway_method.todos[each.key].http_method

  integration_http_method = "POST"

  type = "AWS_PROXY"

  uri = aws_lambda_function.todos[each.key].invoke_arn

}

resource "aws_lambda_permission" "api_gateway" {

  for_each = local.api_methods

  statement_id = "AllowExecution-${each.key}"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.todos[each.key].function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"

}

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.todos.id,
      aws_api_gateway_resource.todo_id.id,
      aws_api_gateway_method.todos,
      aws_api_gateway_integration.todos
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.todos
  ]
}

resource "aws_api_gateway_stage" "dev" {

  deployment_id = aws_api_gateway_deployment.deployment.id

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  stage_name = var.environment

  tags = local.common_tags

}