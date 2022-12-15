#### Python Code to return a simple message when a you enter an URL in a browser #####
## Create a new file and name it lambda_function.py. Zip it and place it in the same directory as this file####
def lambda_handler(event, context):
 Print the event data
    print(event)
    
 Return a simple message
   return "Hello, this is a basic AWS Lambda function!"
