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

resource "aws_api_gateway_method" "create_todo" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  resource_id = aws_api_gateway_resource.todos.id

  http_method = "POST"

  authorization = "NONE"

}

resource "aws_api_gateway_integration" "create_todo" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  resource_id = aws_api_gateway_resource.todos.id

  http_method = aws_api_gateway_method.create_todo.http_method

  integration_http_method = "POST"

  type = "AWS_PROXY"

  uri = aws_lambda_function.todos["createTodo"].invoke_arn

}

resource "aws_lambda_permission" "api_gateway_create" {

  statement_id = "AllowExecutionFromAPIGateway"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.todos["createTodo"].function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"

}

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  depends_on = [

    aws_api_gateway_integration.create_todo

  ]

}

resource "aws_api_gateway_stage" "dev" {

  deployment_id = aws_api_gateway_deployment.deployment.id

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  stage_name = var.environment

  tags = local.common_tags

}

