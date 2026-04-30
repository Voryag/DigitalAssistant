from fastapi import FastAPI
from app.database import engine, Base
from app.models import User, Note, Task, CalendarEvent, MapRoute, Sheet
from app.routers import auth_router, notes, gitlab_test

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Digital Assistant API")

app.include_router(auth_router.router)
app.include_router(notes.router)
app.include_router(gitlab_test.router)


@app.get("/")
def root():
    return {"status": "ok"}


# Добавляем безопасность в OpenAPI схему
def configure_openapi():
    if app.openapi_schema:
        return
    app.openapi()
    app.openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    app.openapi_schema["security"] = [{"BearerAuth": []}]


configure_openapi()