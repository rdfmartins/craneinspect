from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional

import models
import schemas
import s3_service
from database import engine, get_db

# Instancia as tabelas no DB na inicialização da Pipeline (Abordagem MVP acelerada)
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="CraneInspect API", description="API Core do CraneInspect")

# CORS — permite comunicação do frontend Zero-Build (porta 8080 local)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://127.0.0.1:8080", "null"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "CraneInspect FastAPI Gateway operando com Banco de Dados e S3 Acoplados!"
    }

@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    return {"status": "healthy", "database_active": db.is_active}

# --- ROTAS DE INSPEÇÕES ---

@app.post("/inspections", response_model=schemas.InspectionResponse, status_code=status.HTTP_201_CREATED)
def create_inspection(inspection: schemas.InspectionCreate, db: Session = Depends(get_db)):
    """Entrada primária de nova Vistoria de Grua no Sistema."""
    nova_inspecao = models.Inspection(**inspection.model_dump())
    db.add(nova_inspecao)
    db.commit()
    db.refresh(nova_inspecao)
    return nova_inspecao

@app.get("/inspections", response_model=List[schemas.InspectionResponse])
def get_inspections(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Lista todas as vistorias com paginação via offset (Server-Side SQL)."""
    return db.query(models.Inspection).offset(skip).limit(limit).all()

@app.get("/inspections/{inspection_id}", response_model=schemas.InspectionResponse)
def get_inspection(inspection_id: int, db: Session = Depends(get_db)):
    """Busca uma vistoria específica pelo ID."""
    inspecao = db.query(models.Inspection).filter(models.Inspection.id == inspection_id).first()
    if not inspecao:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vistoria não encontrada.")
    return inspecao

# --- ROTAS DE FOTOS / S3 (ADR-004) ---

@app.post(
    "/inspections/{inspection_id}/photos",
    response_model=schemas.PhotoResponse,
    status_code=status.HTTP_201_CREATED
)
async def upload_inspection_photo(
    inspection_id: int,
    file: UploadFile = File(...),
    description: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """
    Recebe uma imagem de campo via Multipart Form, realiza upload ao S3 privado
    e persiste apenas a `s3_object_key` no banco (NUNCA a URL pública).
    A URL de acesso é gerada sob demanda no endpoint /photos/{id}/url.
    """
    # Validação de tipo de arquivo (SecOps — apenas imagens)
    ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Tipo de arquivo não permitido: {file.content_type}. Use JPEG, PNG ou WebP."
        )

    # Valida existência da vistoria antes de subir o arquivo
    inspecao = db.query(models.Inspection).filter(models.Inspection.id == inspection_id).first()
    if not inspecao:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vistoria não encontrada.")

    # Lê o conteúdo do arquivo em memória e envia para o S3 privado
    file_content = await file.read()
    s3_key = s3_service.upload_file_to_s3(
        file_content=file_content,
        original_filename=file.filename,
        inspection_id=inspection_id
    )

    # Persiste apenas a s3_object_key no banco (ADR-004)
    foto = models.InspectionPhoto(
        inspection_id=inspection_id,
        s3_object_key=s3_key,
        description=description
    )
    db.add(foto)
    db.commit()
    db.refresh(foto)
    return foto

@app.get("/photos/{photo_id}/url", response_model=schemas.PhotoResponse)
def get_photo_presigned_url(photo_id: int, db: Session = Depends(get_db)):
    """
    Gera e injeta, sob demanda, uma Presigned URL temporária (1h) para acesso
    seguro a uma foto privada do S3. O acesso direto ao bucket é impossível
    (Block Public Access habilitado — ADR-004).
    """
    foto = db.query(models.InspectionPhoto).filter(models.InspectionPhoto.id == photo_id).first()
    if not foto:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Foto não encontrada.")

    # Geração on-demand — a URL não é armazenada, existe apenas na resposta desta chamada
    presigned_url = s3_service.generate_presigned_url(foto.s3_object_key)

    # Serializa via Pydantic e injeta a URL temporária antes de retornar
    response = schemas.PhotoResponse.model_validate(foto)
    response.presigned_url = presigned_url
    return response


