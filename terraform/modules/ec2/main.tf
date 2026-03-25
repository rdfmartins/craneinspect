data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ec2_sg" {
  # checkov:skip=CKV_AWS_260: Permitir HTTPS/HTTP web direto
  # checkov:skip=CKV_AWS_24:  A porta 80 ficará aberta
  # checkov:skip=CKV_AWS_382: Docker installation out to the internet require total egress

  name        = "${var.project_name}-ec2-sg"
  description = "Security Group App sem SSH exposto (Modo Arquiteto)"
  vpc_id      = var.vpc_id

  # Ingresso bloqueado para SSH
  # Liberado apenas as portas Web, já que não usamos Load Balancer.

  ingress {
    description = "HTTP Traffic (FinOps MVP)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # checkov:skip=CKV_AWS_260: Necessário pois a EC2 está exposta no IP diretamente para clientes
    # checkov:skip=CKV_AWS_24:  A porta 80 ficará aberta
  }

  ingress {
    description = "HTTPS Traffic (FinOps MVP)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # checkov:skip=CKV_AWS_260: Tráfego HTTPS Web App
  }

  egress {
    description = "Egress total para internet (AWS SSM & Docker repo)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # checkov:skip=CKV_AWS_381: Permite download de libs e pacotes apt-get (Checkov prefere regras fechadas)
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "app" {
  # checkov:skip=CKV_AWS_88: IP Público utilizado intencionalmente por decisão arquitetural (Não há ALB/NAT).
  # checkov:skip=CKV_AWS_135: EC2 EBS não obrigatório para EBS-Optimized (não-requerido no tipo de instância).
  # checkov:skip=CKV_AWS_126: Detailed monitoring disabled for FinOps cost reduction
  # checkov:skip=CKV2_AWS_41: IAM Role está anexada ao Profile, checkov falso positivo.

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  # user_data em base64 com filebase64
  user_data_base64 = filebase64("${path.module}/user_data.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # imdsv2 enforce
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    encrypted = true
    # checkov:skip=CKV_AWS_163: KMS default encryption ensures EBS is encrypted
  }

  # Configuração de FinOps (Instância Spot) - Comentado para uso estrito do Free Tier (On-Demand)
  # instance_market_options {
  #  market_type = "spot"
  #  spot_options {
  #    # Definimos max_price se precisarmos, mas vazio usa o On-Demand cap.
  #  }
  # }


  tags = {
    Name = "${var.project_name}-ec2-app"
  }
}
