provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
  for_each = var.s3_bucket_names

  bucket = "${each.value}-${var.project}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  for_each = aws_s3_bucket.terraform_state
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  for_each = aws_s3_bucket.terraform_state
  bucket   = each.value.id
  acl      = "private"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  for_each = var.s3_bucket_names

  name           = "${each.value}-${var.project}-terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
