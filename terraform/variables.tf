variable "aws_region" {
  description = "Região da AWS para deploy"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil da AWS para autenticação"
  type        = string
  default     = "Rodolfo"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "craneinspect"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}
