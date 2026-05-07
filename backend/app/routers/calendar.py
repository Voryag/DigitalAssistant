from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.database import get_db
from app.models import CalendarEvent
from app.auth import get_current_user
from app.models import User
from app.schemas import EventCreate, EventResponse
from pydantic import BaseModel

router = APIRouter(
    prefix="/calendar",
    tags=["calendar"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)

@router.get("/", response_model=list[EventResponse])
def get_events(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    events = db.query(CalendarEvent).filter(CalendarEvent.user_id == current_user.id).all()
    # Преобразуем datetime в строки
    result = []
    for e in events:
        result.append({
            "id": e.id,
            "user_id": e.user_id,
            "title": e.title,
            "content": e.content,
            "start_time": e.start_time.isoformat(),
            "end_time": e.end_time.isoformat(),
        })
    return result


@router.post("/", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
def create_event(data: EventCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    event = CalendarEvent(
        user_id=current_user.id,
        title=data.title,
        content=data.content,
        start_time=datetime.fromisoformat(data.start_time),
        end_time=datetime.fromisoformat(data.end_time),
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return {
        "id": event.id,
        "user_id": event.user_id,
        "title": event.title,
        "content": event.content,
        "start_time": event.start_time.isoformat(),
        "end_time": event.end_time.isoformat(),
    }


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(event_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    event = db.query(CalendarEvent).filter(CalendarEvent.id == event_id, CalendarEvent.user_id == current_user.id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Событие не найдено")
    db.delete(event)
    db.commit()
    return None