terraform {
  backend "s3" {
    bucket                  = "tf-s3-state-09"
    dynamodb_table          = "tf-state-lock-09"
    key                     = "my-terraform-project"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
  region                  = terraform.workspace == "test" ? "us-east-1" : "us-west-2"
}


# resource "aws_s3_bucket" "simple_bucket" {
#   bucket = "tf-s3-state-10"
#   acl    = "private"

#   tags = {
#     Name = "myBucketTagName"
#   }
# }

# resource "aws_dynamodb_table" "tf-state-lock-10" {
#   name = "tf-state-lock-10"
#   has_key = "LockID"

# }

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name" = "custom"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "public"
  }
}
