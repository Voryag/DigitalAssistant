from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List

from app.auth import get_current_user
from app.lm_studio_client import parse_user_request

router = APIRouter(
    prefix="/ai",
    tags=["ai"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

class ParseRequest(BaseModel):
    text: str

class ParseResponse(BaseModel):
    intent: str
    tags: List[str]

@router.post("/parse", response_model=ParseResponse)
async def parse_text(request: ParseRequest):
    result = parse_user_request(request.text)
    return ParseResponse(intent=result["intent"], tags=result["tags"])
