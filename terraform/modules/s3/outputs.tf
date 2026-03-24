output "bucket_id" {
  description = "Nome do S3 Bucket criado"
  value       = aws_s3_bucket.photos.id
}

output "bucket_arn" {
  description = "ARN do bucket gerado para uso em policies de IAM"
  value       = aws_s3_bucket.photos.arn
}
