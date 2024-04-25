### Get AMI ID of the latest EMR image:

aws ec2 describe-images --region eu-west-1 --owners 286198878708 --filters 'Name=architecture,Values=x86_64' 'Name=name,Values=emr-release-build EMR AMI Recipe 650*' --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' --output text