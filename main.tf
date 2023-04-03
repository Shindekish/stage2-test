resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tag = {
        name = "stage2_test"
    }
}

########################################################
resource "aws_subnet" "public_subnet" {
    vpc_id = data.aws_vpc.vpc
    cidr_block = 10.0.1.0/24
    availability_zones     = ["ap-south-1a"]

    
    tag = {
        name = stage2_test_public_subnet
    }
}

######################################################

resource "aws_subnet" "private_subnet" {
    vpc_id = data.aws_vpc.vpc
    cidr_block = 10.0.2.0/24
    availability_zones      = ["ap-south-1b"]

    tag = {
        name = stage2_test_private_subnet
    }

}

###################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.VPC
  tags = {
    Name = "stage2_test_igw"
  }
}

####################################################################
resource "aws_nat_gateway" "Nat_gateway" {
  vpc_id = data.aws_vpc.VPC
  
  subnet_id   = "aws_subnet.public_subnet.id"

  tags = {
    Name = "stage2_test_Nat_gatway"
  }
}

#########################################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.VPC

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "stage2_test_public_route_table"
  }
}

##########################################################################
resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.VPC

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_nat_gateway.nat

  tags = {
    Name = "stage2_test_private_route_table"
  }
}
}


resource "aws_s3_bucket" "b" {

  tags = {
    Name        = "kishor-stage2_test-bucket"
    Environment = "Dev"
  }
}
################################################################################

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

#################################################################################
resource "aws_security_group" "Sgw" {
  name        = "Sgw"
  description = "Sgw inbound traffic"
  vpc_id      = data.aws_vpc.vpc

  ingress {
    description      = "Sgw from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage2_test_security_group"
  }
}

######################################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               =  "DevOps-Candidate-Lambda-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
