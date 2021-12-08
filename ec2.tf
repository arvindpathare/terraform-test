resource "aws_instance" "role-test" {
  ami = "ami-0d37e07bd4ff37148"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "aws-test"
  user_data = <<-EOL
  #!/bin/bash -xe

  sudo yum update -y
  sudo yum install -y awslogs
  sudo yum install -y git
  git clone https://github.com/arvindpathare/terraform-test.git
  sudo systemctl start awslogsd
  sudo systemctl enable awslogsd.service
  sudo amazon-linux-extras install docker -y
  sudo yum install docker -y 
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  docker build -t mynginxterra .
  aws s3 cp s3://s3-terraform-bucket-srk/index.html /home/ec2-user
  
  EOL
  tags = {
    Name = "Terratest"
  }
}
