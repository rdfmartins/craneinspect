import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Resiliência: Puxa do ambiente (Docker) com fallbacks
DB_USER = os.getenv("DB_USER", "craneadmin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "cranepassword")
DB_HOST = os.getenv("DB_HOST", "db")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "craneinspect_db")

# Conexão nativa com PostgreSQL via Psycopg2
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Engine do banco (Padrão de estabilidade sem over-engineering)
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para declaração de metadados
Base = declarative_base()

# Dependency de injeção segura para o FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
