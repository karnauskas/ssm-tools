# This is an example, adapt to your usecase

data "template_file" "emr-ssm-policy" {
  # The template provides a generic ssm execution policy
  # Below, we will specify which commands can be run on which instances
  template = "${file("./policies/ssm-executor.tpl")}"
  vars {
    # Which command will be allowed to run. Note that AWS-RunShellScript is very broad and
    # can be used to execute arbitrary commands on the instance. It's better to replace
    # this with a custom script registered in SSM when possible.
    allowed_command = "arn:aws:ssm:us-east-1::document/AWS-RunShellScript"

    # Bucket where output will be stored
    bucket_name = "your-bucket-name"

    # Which EC2 instances are allowed to run the command.
    # See: http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-rc-setting-up-cmdsec.html
    ec2_condition = <<EOF
      "Condition":{
        "StringLike":{
          "ssm:resourceTag/example":[
            "foobar"
          ],
          "ssm:resourceTag/another_tag":[
            "some_value"
          ]
        }
      }
    EOF
  }
}

resource "aws_iam_role_policy" "ssm-executor" {
  name = "ssm-executor"
  policy = "${data.template_file.emr-ssm-policy.rendered}"
  role = "${aws_iam_role.ssm-executor.name}"
}

