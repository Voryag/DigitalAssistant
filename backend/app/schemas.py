from pydantic import BaseModel
from typing import Optional, List


# ============ AUTH ============
class UserCreate(BaseModel):
    username: str
    email: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    username: str
    password: str


# ============ NOTES ============
class NoteCreate(BaseModel):
    title: str
    content: Optional[str] = None
    ai_tags: Optional[List[str]] = None


class NoteResponse(BaseModel):
    id: int
    user_id: int
    title: str
    content: Optional[str] = None
    ai_tags: Optional[List[str]] = None

    class Config:
        from_attributes = True


# ============ Tasks ============
class TaskCreate(BaseModel):
    title: str
    content: Optional[str] = None
    project: Optional[str] = None
    priority: Optional[str] = "medium"
    due_date: Optional[str] = None
    ai_tags: Optional[List[str]] = []

class TaskResponse(BaseModel):
    id: int
    user_id: int
    title: int
    content: Optional[str] = None
    project: Optional[str] = None
    priority: Optional[str] = None
    due_date: Optional[str] = None
    ai_tags: Optional[List[str]] = []

    class Config:
        from_attributes = True

# ============ Calendar ============
class EventCreate(BaseModel):
    title: str
    content: Optional[str] = None
    start_time: str
    end_time: str


class EventResponse(BaseModel):
    id: int
    title: str
    content: Optional[str] = None
    start_time: str
    end_time: str

    class Config:
        from_attributes = True