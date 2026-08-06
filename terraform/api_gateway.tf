resource "aws_api_gateway_rest_api" "post_api" {

  name = "${local.name_prefix}-api"

  description = "Post CRUD API"

  endpoint_configuration {

    types = ["REGIONAL"]

  }

  tags = local.common_tags

}

resource "aws_api_gateway_resource" "posts" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  parent_id = aws_api_gateway_rest_api.post_api.root_resource_id

  path_part = "posts"

}

resource "aws_api_gateway_resource" "post_id" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  parent_id = aws_api_gateway_resource.posts.id

  path_part = "{id}"

}

locals {

  api_methods = {

    createPost = {

      resource = aws_api_gateway_resource.posts.id

      method = "POST"

    }

    getPosts = {

      resource = aws_api_gateway_resource.posts.id

      method = "GET"

    }

    getPostById = {

      resource = aws_api_gateway_resource.post_id.id

      method = "GET"

    }

    updatePost = {

      resource = aws_api_gateway_resource.post_id.id

      method = "PUT"

    }

    deletePost = {

      resource = aws_api_gateway_resource.post_id.id

      method = "DELETE"

    }

  }

}

resource "aws_api_gateway_method" "posts_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.posts.id

  http_method = "OPTIONS"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "posts_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.posts.id

  http_method = aws_api_gateway_method.posts_options.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "posts_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.posts.id

  http_method = aws_api_gateway_method.posts_options.http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {

    "method.response.header.Access-Control-Allow-Origin" = true

    "method.response.header.Access-Control-Allow-Headers" = true

    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "posts_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.posts.id

  http_method = aws_api_gateway_method.posts_options.http_method

  status_code = aws_api_gateway_method_response.posts_options.status_code

  response_parameters = {

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"

    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.posts_options
  ]
}









resource "aws_api_gateway_method" "post_id_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.post_id.id

  http_method = "OPTIONS"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_id_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.post_id.id

  http_method = aws_api_gateway_method.posts_options.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "post_id_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.post_id.id

  http_method = aws_api_gateway_method.posts_options.http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {

    "method.response.header.Access-Control-Allow-Origin" = true

    "method.response.header.Access-Control-Allow-Headers" = true

    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "post_id_options" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = aws_api_gateway_resource.post_id.id

  http_method = aws_api_gateway_method.posts_options.http_method

  status_code = aws_api_gateway_method_response.posts_options.status_code

  response_parameters = {

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"

    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.posts_options
  ]
}









resource "aws_api_gateway_method" "posts" {

  for_each = local.api_methods

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = each.value.resource

  http_method = each.value.method

  authorization = "NONE"

}

resource "aws_api_gateway_integration" "posts" {

  for_each = local.api_methods

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  resource_id = each.value.resource

  http_method = aws_api_gateway_method.posts[each.key].http_method

  integration_http_method = "POST"

  type = "AWS_PROXY"

  uri = aws_lambda_function.posts[each.key].invoke_arn

}

resource "aws_lambda_permission" "api_gateway" {

  for_each = local.api_methods

  statement_id = "AllowExecution-${each.key}"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.posts[each.key].function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.post_api.execution_arn}/*/*"

}

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.posts.id,
      aws_api_gateway_resource.post_id.id,

      aws_api_gateway_method.posts,
      aws_api_gateway_integration.posts,

      aws_api_gateway_method.posts_options,
      aws_api_gateway_integration.posts_options,

      aws_api_gateway_method.post_id_options,
      aws_api_gateway_integration.post_id_options
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.posts
  ]
}

resource "aws_api_gateway_stage" "dev" {

  deployment_id = aws_api_gateway_deployment.deployment.id

  rest_api_id = aws_api_gateway_rest_api.post_api.id

  stage_name = var.environment

  tags = local.common_tags

}