from fastapi import FastAPI

app = FastAPI(title="CraneInspect API", description="API Core do CraneInspect")

@app.get("/")
def read_root():
    return {
        "status": "online", 
        "message": "CraneInspect FastAPI Gateway operando!"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}
