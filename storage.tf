resource "aws_s3_bucket" "private" {
  bucket = "private-pragmatic-terraform2"
  
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}




resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "public" {
  bucket = "public-pragmatic-terraform2"
#   acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://exapmle.com"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-pragmatic-terraform2"
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  policy =data.aws_iam_policy_document.alb_log.json
}


#ELBアカウントIDの取得
data "aws_elb_service_account" "tf_elb_service_account" {}

data "aws_iam_policy_document" "alb_log" {
  statement {
    actions = ["s3:PutObject"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.tf_elb_service_account.id}:root"]
    }
  }
}




resource "aws_s3_bucket" "artifact" {
  bucket = "artifact-pragmatic-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}


resource "aws_s3_bucket" "operation" {
  bucket = "operation-pragmatic-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}





