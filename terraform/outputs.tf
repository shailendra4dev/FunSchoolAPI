output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_names" {

  value = [
    for lambda in aws_lambda_function.todos :
    lambda.function_name
  ]

}

output "api_url" {

  value = aws_api_gateway_stage.dev.invoke_url

}