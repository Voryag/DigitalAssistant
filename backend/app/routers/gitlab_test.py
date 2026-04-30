from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from app.auth import get_current_user
from app.gitlab_client import create_gitlab_issue

router = APIRouter(
    prefix="/gitlab",
    tags=["gitlab"],
    dependencies=[Depends(get_current_user)]
)


class GitLabIssueRequest(BaseModel):
    title: str
    description: Optional[str] = None
    labels: Optional[List[str]] = []

class GitLabIssueResponse(BaseModel):
    gitlab_id: int
    gitlab_iid: int
    gitlab_url: str

@router.post("/create-issue", response_model=GitLabIssueResponse)
async def create_issue(request: GitLabIssueRequest):
    try:
        result = await create_gitlab_issue(
            title=request.title,
            description=request.description,
            labels=request.labels
        )

        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка Gitlab API: {str(e)}")
    