from fastapi import FastAPI
from app.database import engine, Base
from app.routers import auth_router

app = FastAPI(title="Digital Assistant API")

app.include_router(auth_router.router)

@app.get("/")
def root():
    return {"status", "ok"}