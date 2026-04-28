from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Notes
from app.schemas import NoteCreate, NoteResponse
from app.auth import get_current_user
from app.models import User

router = APIRouter(prefix="/notes", tags=["notes"])

#Получить все заметки текущего пользователя
@router.get("/", response_model=List[NoteResponse])
def get_notes(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    notes = db.query(Notes).filter(Notes.user_id = current_user.id).all()
    return notes

#Создать заметку
@router.post("/", response_model=NoteResponse, status_code=status.HTTP_201_CREATED)
def create_note(
    note_data: NoteCreate,
    db: Session = Depends(get_current_user)
):
    note = Notes(
        user_id=current_user.id
        title=note_data.title,
        content=note_data.content,
        ai_tags=note_data.ai_tags
    )
    db.add(note)
    db.commit()
    db.refresh(note)
    return note

#Обновить заметку
@router.put("/{note_id}", response_model=NoteResponse)
def update_note(
    note_id: int,
    note_data: NoteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    note = db.query(Notes).filter(Notes.id == note_id, Note.user_id == current_user.id).first() 
    if not note:
        raise HTTPException(status_code=404, detail="Заметка не найдена")
    
    note.title = note_data.title
    note.content = note_data.content
    note.ai_tags = note_data.ai_tags
    db.commit()
    db.refresh(note)
    return note

#Удалить заметку
@router.delete("/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    note = db.query(Notes).filter(Notes.id == note_id, Notes.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Заметка не найдена")
    
    db.delete(note)
    db.commit()
    return None