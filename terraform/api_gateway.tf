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
      aws_api_gateway_integration.posts
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