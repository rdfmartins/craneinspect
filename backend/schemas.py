from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional
from models import InspectionStatus


# ----------------- FOTOS -----------------
class PhotoCreate(BaseModel):
    """Payload interno usado após o upload para registrar a foto no banco."""
    description: Optional[str] = None

class PhotoBase(BaseModel):
    s3_object_key: str
    description: Optional[str] = None

class PhotoResponse(PhotoBase):
    id: int
    inspection_id: int
    created_at: datetime
    # URL assinada injetada on-demand pelo endpoint — NUNCA armazenada no banco (ADR-004)
    presigned_url: Optional[str] = None

    class Config:
        from_attributes = True

# ----------------- INSPEÇÃO ---------------
class InspectionBase(BaseModel):
    crane_tag: str = Field(..., max_length=50, description="Tag ou Chassi identificador da Grua.")
    inspector_name: str = Field(..., max_length=100)
    status: InspectionStatus = InspectionStatus.PENDING
    notes: Optional[str] = None

class InspectionCreate(InspectionBase):
    pass
    
class InspectionResponse(InspectionBase):
    id: int
    inspection_date: datetime
    created_at: datetime
    photos: List[PhotoResponse] = []

    class Config:
        from_attributes = True
