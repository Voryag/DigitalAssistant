from fastapi import APIRoute, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Notes
from app.schemas import NoteCreate, NoteResponse