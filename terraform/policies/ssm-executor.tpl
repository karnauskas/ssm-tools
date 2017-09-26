{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:ListDocuments",
        "ssm:DescribeDocument*",
        "ssm:GetDocument",
        "ssm:DescribeInstance*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": [
        "${allowed_command}"
      ]
    },
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:*:*:instance/*"
      ],
      ${ec2_condition}
    },
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow", "Resource": [
        "arn:aws:s3:::${bucket_name}/*",
        "arn:aws:s3:::${bucket_name}"
      ]
    },
    {
      "Action": [
        "ssm:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "ec2:Describe*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
