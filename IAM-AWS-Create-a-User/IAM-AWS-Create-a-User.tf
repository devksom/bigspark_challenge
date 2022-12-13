#Create IAM group resource called bgspadmins
#Create a group called admin and place it in the path called users for easy organisation
resource "aws_iam_group" "bgspadminsgp" {
  name = "admin"
  path = "/users/"
}

#create an IAM user resource called bgspusers
#create a user with name bgspadmin
resource "aws_iam_user" "bgspadminusers" {
  name          = "bgspadmin1"
  path          = "/"
  force_destroy = true
  tags = {
    "Role" = "DevOps"
  }
}
resource "aws_iam_user_login_profile" "bgsploginprofile" {
  user= aws_iam_user.bgspadminusers.name
  password_reset_required = true
  #pgp_key = "keybase:some_person_that_exists"

}
output "password" {
    value = aws_iam_user_login_profile.bgsploginprofile.encrypted_password
  
}
#create an IAM greoup membership resource called bgspgpmembership
#create a membership called adminmembership
#add the user to the admin group via adminmembership
resource "aws_iam_group_membership" "bgspgpmembership" {
  name = "adminmembership"
  users = [aws_iam_user.bgspadminusers.name]


  group = aws_iam_group.bgspadminsgp.name
}
data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_group_policy_attachment" "bgspgppolicy" {
    group      = aws_iam_group.bgspadminsgp.name
    policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}
  
