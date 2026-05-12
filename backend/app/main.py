from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.models import User, Note, Task, CalendarEvent, MapRoute, Sheet
from app.routers import auth_router, notes, gitlab_test, ai, tasks, calendar, search, routes, sheets

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Digital Assistant API")

#Разрешение запросов из Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(notes.router)
app.include_router(gitlab_test.router)
app.include_router(ai.router)
app.include_router(tasks.router)
app.include_router(calendar.router)
app.include_router(search.router)
app.include_router(routes.router)
app.include_router(sheets.router)


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