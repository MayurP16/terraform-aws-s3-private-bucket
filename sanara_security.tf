resource "aws_sns_topic" "_events" {
  name = "-events"
}

resource "aws_sns_topic_policy" "_events_policy" {
  arn = aws_sns_topic._events.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3Publish"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic._events.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket..arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "_notifications" {
  bucket = aws_s3_bucket..id
  topic {
    topic_arn = aws_sns_topic._events.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sns_topic_policy._events_policy]
}
