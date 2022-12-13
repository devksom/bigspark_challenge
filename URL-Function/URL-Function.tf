# Create a Lambda function resource
resource "aws_lambda_function" "lambda_function" {
  function_name="URL_function"
  # Set the runtime to Python 3.8
  runtime = "python3.8"

  # Set the function code to the contents of a local file
  filename = "lambda_function.zip"

  # Set the function's handler to the name of the file and the name of the function
  # In this case, the file is named "hello_function.py" and the function is named "handler"
  handler = "lambda_function.lambda_handler"

  # Create an IAM role for the function to use
  role = aws_iam_role.lambda_role.arn
}

# Create an IAM role for the Lambda function to use
resource "aws_iam_role" "lambda_role" {
  # Set the role's trust policy to allow it to be assumed by Lambda
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"

  

cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
  
}

#### Python Code to return a simple message when a you enter an URL in a browser #####
## Create a new file and name it lambda_function.py. Zip it and place it in the same directory as this file####
#def lambda_handler(event, context):
#    # Print the event data
#    print(event)
    
#    # Return a simple message
#    return "Hello, this is a basic AWS Lambda function!"

