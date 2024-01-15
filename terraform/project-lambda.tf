resource "aws_lambda_function" "lambda_function" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../serverless/my_deployment_package.zip"
  function_name = "handler"
  role          = aws_iam_role.Lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../../serverless/my_deployment_package.zip")

  runtime = "python3.11"

  environment {
    variables = {
      MAILGUN_API_KEY = var.mailgun_api_key
      MAILGUN_DOMAIN  = var.mailgun_domain
      MAILGUN_SENDER  = var.mailgun_sender
      DYNAMODB_TABLE  = aws_dynamodb_table.EmailTrack.name
      AWS_REG         = var.region
    }
  }
  timeout = 300
}

resource "aws_lambda_permission" "dynamodb_permission" {
  statement_id  = "AllowSNSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sns.amazonaws.com"
}