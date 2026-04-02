import os
import uuid
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
from fastapi import HTTPException, status

# ==========================================
# CONFIGURAÇÃO S3 - Injeção via Ambiente
# NUNCA expor credenciais hardcoded (SecOps)
# ==========================================
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME", "")

# Curta duração: URLs expiram em 1 hora (3600s) por segurança (ADR-004)
PRESIGNED_URL_EXPIRATION = int(os.getenv("PRESIGNED_URL_EXPIRATION", "3600"))


def _get_s3_client():
    """
    Factory interna do cliente S3.
    As credenciais são resolvidas pela cadeia padrão do Boto3:
    1. Variáveis de ambiente (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY)
    2. IAM Role da EC2 (Mecanismo preferido em produção na AWS)
    Isso garante Zero Hardcode em qualquer ambiente.
    """
    return boto3.client("s3", region_name=AWS_REGION)


def upload_file_to_s3(file_content: bytes, original_filename: str, inspection_id: int) -> str:
    """
    Realiza o upload de um arquivo para o S3 privado.
    Retorna a s3_object_key (caminho interno), NUNCA a URL pública.

    Estrutura do path no bucket:
        inspections/{inspection_id}/{uuid}-{filename}
    """
    if not S3_BUCKET_NAME:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Configuração S3_BUCKET_NAME ausente no ambiente do servidor."
        )

    # UUID garante unicidade absoluta e previne colisões de nomes - SecOps
    unique_key = f"inspections/{inspection_id}/{uuid.uuid4()}-{original_filename}"

    try:
        s3_client = _get_s3_client()
        s3_client.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=unique_key,
            Body=file_content,
            # Nenhum ACL público — o bucket respeita o Block Public Access (ADR-004)
        )
        return unique_key

    except NoCredentialsError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Credenciais AWS não encontradas. Configure as variáveis de ambiente ou IAM Role."
        )
    except ClientError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Falha no upload para S3: {e.response['Error']['Message']}"
        )


def generate_presigned_url(s3_object_key: str) -> str:
    """
    Gera uma URL temporária e assinada para acesso a um objeto privado do S3.
    URL expira em PRESIGNED_URL_EXPIRATION segundos (padrão: 3600s / 1 hora).

    NENHUM acesso ocorre sem passar por esta função — a URL pública direta
    é matematicamente inválida (Block Public Access do Bucket habilitado).
    """
    if not S3_BUCKET_NAME:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Configuração S3_BUCKET_NAME ausente no ambiente do servidor."
        )

    try:
        s3_client = _get_s3_client()
        url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": S3_BUCKET_NAME, "Key": s3_object_key},
            ExpiresIn=PRESIGNED_URL_EXPIRATION,
        )
        return url

    except NoCredentialsError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Credenciais AWS não encontradas. Configure as variáveis de ambiente ou IAM Role."
        )
    except ClientError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Falha ao gerar Presigned URL: {e.response['Error']['Message']}"
        )


def delete_object_from_s3(s3_object_key: str) -> None:
    """
    Remove permanentemente um objeto do S3.
    Usado quando uma foto de inspeção é removida do banco (Cascade de dados).
    """
    try:
        s3_client = _get_s3_client()
        s3_client.delete_object(Bucket=S3_BUCKET_NAME, Key=s3_object_key)
    except ClientError as e:
        # Log do erro sem interromper o fluxo (o DB já deletou o registro)
        print(f"[WARNING] Falha ao remover objeto S3 '{s3_object_key}': {e.response['Error']['Message']}")
