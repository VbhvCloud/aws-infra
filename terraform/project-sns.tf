resource "aws_sns_topic" "image_updates" {
  name = "image-updates-topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.image_updates.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}