from fastapi import FastAPI
from fastapi.responses import JSONResponse

from app.utils import utc_now

app = FastAPI(
    title="This is a Template Aplication",
    description="This is a Template Aplication",
    version="1.0.0"
)


@app.get("/")
def read_root():
    return {"message": "Hello, World!"}


@app.get("/health")
def health_check():
    """
    Health check endpoint returning service status and current timestamp.
    """
    return JSONResponse(
        status_code=200,
        content={
            "status": "ok",
            "timestamp": utc_now().isoformat() + "Z"
        }
    )
