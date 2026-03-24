variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID da Subnet Publica (onde a EC2 vai rodar)"
  type        = string
}

variable "instance_type" {
  description = "Tamanho da instancia"
  type        = string
  default     = "t3.medium" # Requisito FinOps: Spot
}
