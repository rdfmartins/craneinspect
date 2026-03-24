variable "project_name" {
  description = "Nome do projeto para nomeação do bucket"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, prod)"
  type        = string
  default     = "dev"
}
