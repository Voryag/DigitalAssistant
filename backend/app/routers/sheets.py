from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List

from app.database import get_db
from app.models import Sheet, User
from app.auth import get_current_user

router = APIRouter(
    prefix="/sheets",
    tags=["sheets"],
    dependencies=[Depends(get_current_user)],
    responses={401: {"description": "Unauthorized"}}
)


class SheetCreate(BaseModel):
    title: str
    headers: List[str] = []
    rows: List[List] = []


class RowAdd(BaseModel):
    values: List[str]


@router.get("/")
def get_sheets(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Sheet).filter(Sheet.user_id == current_user.id).all()


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_sheet(data: SheetCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    sheet = Sheet(
        user_id=current_user.id,
        title=data.title,
        headers=data.headers,
        rows=data.rows,
    )
    db.add(sheet)
    db.commit()
    db.refresh(sheet)
    return {
        "id": sheet.id,
        "title": sheet.title,
        "headers": sheet.headers,
        "rows": sheet.rows,
    }


@router.post("/{sheet_id}/rows")
def add_row(sheet_id: int, data: RowAdd, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    sheet = db.query(Sheet).filter(Sheet.id == sheet_id, Sheet.user_id == current_user.id).first()
    if not sheet:
        raise HTTPException(status_code=404, detail="Таблица не найдена")
    
    rows = sheet.rows or []
    rows.append(data.values)
    sheet.rows = rows
    db.commit()
    return {"status": "ok"}


@router.delete("/{sheet_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_sheet(sheet_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    sheet = db.query(Sheet).filter(Sheet.id == sheet_id, Sheet.user_id == current_user.id).first()
    if not sheet:
        raise HTTPException(status_code=404, detail="Таблица не найдена")
    db.delete(sheet)
    db.commit()
    return None