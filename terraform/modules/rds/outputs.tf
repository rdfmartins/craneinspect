output "db_endpoint" {
  description = "A string conexão do PostgreSQL (sem schema)"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  description = "Nome do banco da aplicacao"
  value       = aws_db_instance.postgres.db_name
}
