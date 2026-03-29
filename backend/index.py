"""
index.py — Sakhya backend entry point.
Launches the FastAPI app using uvicorn.
"""
import os
from dotenv import load_dotenv
import uvicorn

load_dotenv()

if __name__ == "__main__":
    host = os.getenv("BACKEND_HOST", "0.0.0.0")
    port = int(os.getenv("BACKEND_PORT", "5001"))
    uvicorn.run("app.main:app", host=host, port=port, reload=False)
