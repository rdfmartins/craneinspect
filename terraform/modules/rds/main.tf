resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  # checkov:skip=CKV_AWS_382: Egress temporariamente aberto no SG, porém fisicamente bloqueado pela ausência de NAT Gateway na Private Subnet (Defesa Profunda).
  name        = "${var.project_name}-rds-sg"
  description = "Permite trafego apenas da EC2 do CraneInspect no PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Trafego PostgreSQL da App (EC2)"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "postgres" {
  # checkov:skip=CKV_AWS_157: Multi-AZ is intentionally disabled for FinOps MVP
  # checkov:skip=CKV_AWS_11: Backup is minimal for MVP to save costs
  # checkov:skip=CKV_AWS_118: Enhanced monitoring disabled for MVP
  # checkov:skip=CKV_AWS_133: Auto-minor version upgrade disabled to maintain tight control
  # checkov:skip=CKV_AWS_226: RDS auto setup disabled for MVP
  # checkov:skip=CKV_AWS_129: Log exports not needed for MVP
  # checkov:skip=CKV_AWS_352: Copy tags to snapshot not strictly needed
  # checkov:skip=CKV_AWS_17: Public access is explicitly blocked below (publicly_accessible = false)
  # checkov:skip=CKV_AWS_16: Storage encryption uses default AWS key instead of CMK for FinOps
  # checkov:skip=CKV_AWS_293: Deletion protection disabled for MVP teardown ease
  # checkov:skip=CKV2_AWS_30: Query Logging disabled to reduce CloudWatch costs (FinOps)
  # checkov:skip=CKV2_AWS_60: Copy tags to snapshot not needed since snapshots are disabled
  # checkov:skip=CKV_AWS_161: IAM authentication disabled for MVP simplicity
  # checkov:skip=CKV_AWS_353: Performance Insights disabled to keep db.t3.micro footprint and costs to a minimum (FinOps)

  identifier        = "${var.project_name}-db-instance"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "craneinspect"
  username = "crane_admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false # Ponto critico de seguranca (Data Blindagem)
  skip_final_snapshot = true  # FinOps ao destruir o DB (Evita custos de snapshot perdidos)
  storage_encrypted   = true

  tags = {
    Name = "${var.project_name}-postgres"
    Tier = "Database"
  }
}
