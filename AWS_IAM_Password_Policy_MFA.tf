resource "aws_iam_account_password_policy" "bgsppwdpolicy" {
    minimum_password_length = 8
    require_numbers = true
    password_reuse_prevention=1

    
  
}
