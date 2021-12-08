resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}
resource "aws_iam_role" "test_role_cloud" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "*"
    ]
  }
 ]
}
EOF

   tags = {
      tag-key = "tag-value"
}
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_instance" "role-test" {
  ami = "ami-0d37e07bd4ff37148"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "aws-test"
  user_data = <<-EOL
  #!/bin/bash -xe

  sudo yum update -y
  sudo yum install -y awslogs
  sudo systemctl start awslogsd
  sudo systemctl enable awslogsd.service
  sudo amazon-linux-extras install docker -y
  sudo yum install docker -y 
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  docker info
  aws s3 cp s3://s3-terraform-bucket-srk/index.html /home/ec2-user
  docker run -v /home/ec2-user:/usr/share/nginx/html:ro -p 8080:80 -d nginx
  EOL
  tags = {
    Name = "Terratest"
  }
}
