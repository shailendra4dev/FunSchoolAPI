data "aws_iam_policy_document" "lambda_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]

    }

    actions = [
      "sts:AssumeRole"
    ]

  }

}

resource "aws_iam_role" "lambda_role" {

  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags

}

data "aws_iam_policy_document" "lambda_permissions" {

  statement {

    effect = "Allow"

    actions = [

      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan"

    ]

    resources = [
      aws_dynamodb_table.posts.arn
    ]

  }

}

resource "aws_iam_policy" "lambda_policy" {

  name = "${local.name_prefix}-lambda-policy"

  policy = data.aws_iam_policy_document.lambda_permissions.json

  tags = local.common_tags

}

resource "aws_iam_role_policy_attachment" "lambda_attach" {

  role = aws_iam_role.lambda_role.name

  policy_arn = aws_iam_policy.lambda_policy.arn

}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}