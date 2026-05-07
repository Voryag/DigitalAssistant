from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models import Note, Task, CalendarEvent, User
from app.auth import get_current_user

router = APIRouter(
    prefix="/search",
    tags=["search"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

@router.get("/")
def search(
    q: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    results = []

    # Поиск по заметкам
    notes = db.query(Note).filter(
        Note.user_id == current_user.id,
        (Note.title.ilike(f"%{q}%")) | (Note.content.ilike(f"%{q}%"))
    ).all()
    for note in notes:
        results.append({
            "type": "note",
            "id": note.id,
            "title": note.title,
            "snippet": (note.content or "")[:100],
        })

    # Поиск по задачам
    tasks = db.query(Task).filter(
        Task.user_id == current_user.id,
        (Task.title.ilike(f"%{q}%")) | (Task.content.ilike(f"%{q}%"))
    ).all()
    for task in tasks:
        results.append({
            "type": "task",
            "id": task.id,
            "title": task.title,
            "snippet": (task.description or "")[:100],
        })

    # Поиск по календарю
    events = db.query(CalendarEvent).filter(
        CalendarEvent.user_id == current_user.id,
        CalendarEvent.title.ilike(f"%{q}%")
    ).all()
    for event in events:
        results.append({
            "type": "event",
            "id": event.id,
            "title": event.title,
            "snippet": event.start_time.isoformat(),
        })

    return {"query": q, "results": results}