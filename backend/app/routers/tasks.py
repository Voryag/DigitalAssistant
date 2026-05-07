from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models import Task, User
from app.auth import get_current_user
from app.schemas import TaskCreate, TaskResponse

router = APIRouter(
    prefix="/tasks",
    tags=["tasks"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

@router.get("/", response_model=List[TaskResponse])
def get_tasks(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tasks = db.query(Task).filter(Task.user_id == current_user.id).all()
    result = []
    for t in tasks:
        result.append({
            "id": t.id,
            "user_id": t.user_id,
            "project": t.project,
            "title": t.title,
            "tags": t.tags,
            "content": t.content,
            "start_date": t.start_date.isoformat() if t.start_date else None,
            "due_date": t.due_date.isoformat() if t.due_date else None,
            "priority": t.priority,
            "gitlab_issue_id": t.gitlab_issue_id,
            "gitlab_issue_url": t.gitlab_issue_url,
        })
    return result

@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(task_data: TaskCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = Task(
        user_id=current_user.id,
        project=task_data.project,
        title=task_data.title,
        tags=task_data.tags,
        content=task_data.content,
        due_date=task_data.due_date,
        priority=task_data.priority,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return {
    "id": task.id,
    "user_id": task.user_id,
    "project": task.project,
    "title": task.title,
    "tags": task.tags,
    "content": task.content,
    "start_date": task.start_date.isoformat() if task.start_date else None,
    "due_date": task.due_date.isoformat() if task.due_date else None,
    "priority": task.priority,
    "gitlab_issue_id": task.gitlab_issue_id,
    "gitlab_issue_url": task.gitlab_issue_url,
}


@router.put("/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, task_data: TaskCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")

    task.title = task_data.title
    task.content = task_data.content
    task.project = task_data.project
    task.priority = task_data.priority
    task.due_date = task_data.due_date
    task.ai_tags = task_data.ai_tags

    db.commit()
    db.refresh(task)
    return {
    "id": task.id,
    "user_id": task.user_id,
    "project": task.project,
    "title": task.title,
    "tags": task.tags,
    "content": task.content,
    "start_date": task.start_date.isoformat() if task.start_date else None,
    "due_date": task.due_date.isoformat() if task.due_date else None,
    "priority": task.priority,
    "gitlab_issue_id": task.gitlab_issue_id,
    "gitlab_issue_url": task.gitlab_issue_url,
}


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    db.delete(task)
    db.commit()
    return None