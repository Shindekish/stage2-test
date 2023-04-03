provider "aws" {
  region  = "ap-south-1" # Don't change the region
}

# Add your S3 backend configuration here
terraform {
  backend "s3" {
    bucket = "kishor-stage2_test-bucket"
    key    = "kishor-stage2_test-bucket/path/to/my/key"
    region = "us-south-1"
  }
}
