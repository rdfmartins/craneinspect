from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import enum
from database import Base

class InspectionStatus(str, enum.Enum):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"

class Inspection(Base):
    """
    Modelo Core: Guarda a integridade do ciclo de inspeção de equipamento.
    """
    __tablename__ = "inspections"

    id = Column(Integer, primary_key=True, index=True)
    crane_tag = Column(String(50), index=True, nullable=False)
    inspector_name = Column(String(100), nullable=False)
    inspection_date = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    status = Column(String(20), default=InspectionStatus.PENDING.value)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Definimos a Defesa Profunda e Eager Loading
    # Cascade deleta imagens de vistoria se a vistoria for anulada.
    photos = relationship("InspectionPhoto", back_populates="inspection", cascade="all, delete-orphan")


class InspectionPhoto(Base):
    """
    Guarda as Evidências Fotográficas. 
    A chave s3_object_key interage com Boto3 posteriomente via URL assinada, 
    impedindo acesso irrestrito na internet (Bucket Privado).
    """
    __tablename__ = "inspection_photos"

    id = Column(Integer, primary_key=True, index=True)
    inspection_id = Column(Integer, ForeignKey("inspections.id"), nullable=False)
    
    # Armazena apenas o Caminho/Chave, nunca a URL absoluta por motivos de SecOps e FinOps S3
    s3_object_key = Column(String(255), nullable=False, unique=True)
    description = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    inspection = relationship("Inspection", back_populates="photos")
