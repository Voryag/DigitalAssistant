from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

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

class NoteCreate(BaseModel):
    title: str
    content: Optional[str] = None
    ai_tags: Optional[List[str]] = []

class NoteResponse(BaseModel):
    id: int
    user_id: int
    title: str
    content: Optional[str] = None
    ai_tags: Optional[List[str]] = []

    class Config:
        from_attributes = []