###############      S3 Backend with Dynamodb lock      #################
provider "aws" {
region = "us-east-1"
}

resource "aws_s3_bucket" "tf_remote_state" {
  bucket          = "eks-tfstate-file-22a"
  force_destroy   = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "tf_remote_state" {
  bucket = aws_s3_bucket.tf_remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encrypt" {
  bucket = aws_s3_bucket.tf_remote_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_remote_state_locking" {
  name = "EKS_statefile-lock-22a"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}