from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List

from app.auth import get_current_user
from app.ollama_client import parse_user_request

router = APIRouter(
    prefix="/ai",
    tags=["ai"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

class ParseRequest(BaseModel):
    text: str

class ParseRequest(BaseModel):
    text: str


class ParseResponse(BaseModel):
    intent: str
    title: str
    content: str
    project: str
    tags: str
    priority: str
    due_date: str
    ai_tags: list[str] = []


@router.post("/parse", response_model=ParseResponse)
def parse_text(request: ParseRequest):
    result = parse_user_request(request.text)
    return ParseResponse(
        intent=result["intent"],
        title=result["title"],
        content=result["content"],
        project=result["project"],
        tags=result["tags"],
        priority=result["priority"],
        due_date=result["due_date"],
        start_time=result.get("start_time", ""),
        end_time=result.get("end_time", ""),
        ai_tags=result.get("ai_tags", []),
    )