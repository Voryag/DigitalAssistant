from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models import Task
from app.auth import get_current_user
from app.models import User
from pydantic import BaseModel

router = APIRouter(
    prefix="/tasks",
    tags=["tasks"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    project: Optional[str] = None
    label: Optional[str] = None
    priority: Optional[str] = None
    due_date: Optional[str] = None
    ai_tags: Optional[str] = None

class TaskResponse(BaseModel):
    id: int
    user_id: int
    title: int
    description: Optional[str] = None
    project: Optional[str] = None
    label: Optional[str] = None
    priority: Optional[str] = None
    due_date: Optional[str] = None
    ai_tags: Optional[str] = None

    class Config:
        from_attributes = True

@router.get("/", response_model=List[TaskResponse])
def get_tasks(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Task).filter(Task.user_id == current_user.id).all()

@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(task_data: TaskCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = Task(
        user_id=current_user.id
        title=task_data.title,
        description=task_data.description,
        project=task_data.project,
        label=task_data.label,
        priority=task_data.priority,
        due_date=task_data.due_date,
        ai_tags=task_data.ai_tags,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task

@router.put("/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, task_data: TaskCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    for key, value in task_data.model_dump().items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    return task


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    db.delete(task)
    db.commit()
    return None