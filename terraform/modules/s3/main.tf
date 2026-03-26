data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "photos" {
  # checkov:skip=CKV_AWS_144: Cross-region replication disabled for FinOps cost reduction
  # checkov:skip=CKV_AWS_18: Access logging is disabled for cost and simplicity MVP
  # checkov:skip=CKV_AWS_145: KMS CMK encryption is disabled to save $1/month, using standard AWS managed keys (SSE-S3)
  # checkov:skip=CKV2_AWS_62: Event notifications not needed for MVP

  # Uso do account ID no nome garante unicidade global
  bucket = "${var.project_name}-photos-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-photos-bucket"
    Tier = "Storage"
  }
}

resource "aws_s3_bucket_public_access_block" "photos_block" {
  bucket = aws_s3_bucket.photos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  # Este recurso garante a blindagem. Fotos serão acessíveis APENAS via Presigned-URL
}

resource "aws_s3_bucket_versioning" "photos_versioning" {
  bucket = aws_s3_bucket.photos.id
  versioning_configuration {
    status = "Enabled" # Integridade de dados, evita exclusões não intencionais de fotos no MVP
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "photos_encryption" {
  bucket = aws_s3_bucket.photos.id

  rule {
    # Usando SSE-S3 gratuito para cumprir Checkov e FinOps simultaneamente
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "photos_lifecycle" {
  bucket = aws_s3_bucket.photos.id

  rule {
    id     = "archive-noncurrent-versions"
    status = "Enabled"
    filter {}

    # Move versões antigas de fotos (substituídas) para camada de armazenamento mais barata apos 30 dias
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    # Expira versões substituídas após 90 dias - FinOps 
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    # checkov:skip=CKV2_AWS_61: Checkov doesn't always recognize this nested block properly
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
