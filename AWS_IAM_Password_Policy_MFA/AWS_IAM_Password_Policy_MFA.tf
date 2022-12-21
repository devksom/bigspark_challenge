resource "aws_iam_account_password_policy" "bgsppwdpolicy" {
    minimum_password_length = 8
    require_numbers = true
    password_reuse_prevention=1

     
}
# #Enable MFA for the root user
# Make sure you undertand the implications of uncommenting the code below
# resource "aws_iam_mfa_device" "root_mfa" {
#   user      = "root"
#   serial_number = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/root"
# }

# output "root_mfa_arn" {
#   value = aws_iam_mfa_device.root_mfa.arn
# }
