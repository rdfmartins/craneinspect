from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

import models
import schemas
from database import engine, get_db

# Instancia as tabelas no DB na inicialização da Pipeline (Abordagem MVP acelerada)
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="CraneInspect API", description="API Core do CraneInspect")

@app.get("/")
def read_root():
    return {
        "status": "online", 
        "message": "CraneInspect FastAPI Gateway operando com Banco de Dados Acoplado!"
    }

@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    # Adicionando validação de status da injeção de ORM (FinOps / Monitoramento SecOps)
    return {"status": "healthy", "database_active": db.is_active}

# --- ROTAS DE INSPEÇÕES (CRANE INSPECT) ---

@app.post("/inspections", response_model=schemas.InspectionResponse, status_code=status.HTTP_201_CREATED)
def create_inspection(inspection: schemas.InspectionCreate, db: Session = Depends(get_db)):
    """Rota para entrada primária de nova Vistoria de Grua no Sistema"""
    nova_inspecao = models.Inspection(**inspection.model_dump())
    db.add(nova_inspecao)
    db.commit()
    db.refresh(nova_inspecao)
    return nova_inspecao

@app.get("/inspections", response_model=List[schemas.InspectionResponse])
def get_inspections(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Carrega todas as vistorias abertas no app (Paginado via offset)"""
    return db.query(models.Inspection).offset(skip).limit(limit).all()

