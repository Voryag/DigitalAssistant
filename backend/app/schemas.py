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


# ============ TASKS ============
class TaskCreate(BaseModel):
    title: str
    content: Optional[str] = None    
    project: Optional[str] = None      
    tags: Optional[str] = None         
    due_date: Optional[str] = None     
    priority: Optional[str] = "medium"


class TaskResponse(BaseModel):
    id: int
    user_id: int
    project: Optional[str] = None
    title: str
    tags: Optional[str] = None
    content: Optional[str] = None
    start_date: Optional[str] = None
    due_date: Optional[str] = None
    priority: Optional[str] = None
    gitlab_issue_id: Optional[int] = None
    gitlab_issue_url: Optional[str] = None

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


# ============ Route ============
class RouteCreate(BaseModel):
    name: str
    start_point: str
    end_point: str


class RouteResponse(BaseModel):
    id: int
    name: str
    start_point: str
    end_point: str

    class Config:
        from_attributes = True