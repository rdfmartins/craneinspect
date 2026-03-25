variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS vai operar"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de Subnets Privadas para o DB Subnet Group"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security Group da EC2 para liberar tráfego para o PostgreSQL"
  type        = string
}

variable "db_password" {
  description = "Senha do master user do PostgreSQL"
  type        = string
  sensitive   = true
}
