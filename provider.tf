provider "aws" {
  region  = "ap-south-1" # Don't change the region
}

# Add your S3 backend configuration here
terraform {
  backend "s3" {
    S3 Bucket: "3.devops.candidate.exam"
    bucket = "kishor-stage2_test-bucket"
    key    = "kishor.shinde"
    region = "us-south-1"
  }
}
