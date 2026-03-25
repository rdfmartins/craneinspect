variable "aws_region" {
  description = "Região da AWS para deploy"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil da AWS para autenticação"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Nome do projeto para padronização de nomenclatura"
  type        = string
  default     = "craneinspect"
}

variable "db_password" {
  description = "Senha do master user do PostgreSQL (Passar sempre via TF_VAR_db_password ambiente)"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}
