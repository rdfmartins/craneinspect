output "vpc_id" {
  description = "ID da VPC criado"
  value       = module.vpc.vpc_id
}

output "instance_public_ip" {
  description = "IP Público da instância EC2 (SSM / Docker Host)"
  value       = module.ec2.instance_public_ip
}

output "photos_bucket_name" {
  description = "Nome do bucket S3 de fotos criado"
  value       = module.s3.bucket_id
}

output "db_endpoint" {
  description = "Endereço de acesso ao PostgreSQL para a aplicacao Backend"
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "Nome do banco da aplicacao Backend"
  value       = module.rds.db_name
}
