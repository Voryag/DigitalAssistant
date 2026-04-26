from sqlalchemy import Column, Integer, String, Text, Date, DateTime, Boolean, Float, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB, ARRAY
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), unique=True, nullable=False)
    
class Notes(Base):
    __tablename__ = "notes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text)
    ai_tags = Column(ARRAY(String))

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    project = Column(String(100))
    title = Column(String(255), nullable=False)
    content = Column(Text)
    start_date = Column(Date, server_default=func.current_date())
    due_date = Column(Date)
    priority = Column(String(20), default="medium")
    gitlab_issue_id = Column(Integer)
    gitlab_issue_url = Column(String(500))
    ai_tags = Column(ARRAY(String))

class CalendarEvent(Base):
    __tablename__ = "calendar_events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    reminder = Column(String(50))
    google_event_id = Column(String(255))
    ai_tags = Column(ARRAY(String))

class MapRoute(Base):
    __tablename__ = "maps_routes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    start_point = Column(String(500), nullable=False)
    end_point = Column(String(500), nullable=False)
    yandex_taxi_link = Column(String(500))
    ai_tags = Column(ARRAY(String))

class Sheet(Base):
    __tablename__ = "sheets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    columns = Column(JSONB)
    rows = Column(JSONB)
    google_sheet_id = Column(String(255))
    google_sheet_url = Column(String(500))
    ai_tags = Column(ARRAY(String))