from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from app.database import get_db
from app.models import MapRoute, User
from app.auth import get_current_user
from app.schemas import RouteCreate, RouteResponse

router = APIRouter(
    prefix="/routes",
    tags=["routes"],
    dependencies=[Depends(get_current_user)],  # ← без скобок ()
    responses={401: {"description": "Unauthorized"}}
)

@router.get("/", response_model=list[RouteResponse])
def get_routes(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(MapRoute).filter(MapRoute.user_id == current_user.id).all()

@router.post("/", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
def create_route(data: RouteCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    route = MapRoute(
        user_id=current_user.id,
        name=data.name,
        start_point=data.start_point,
        end_point=data.end_point,
    )
    db.add(route)
    db.commit()
    db.refresh(route)
    return route


@router.delete("/{route_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_route(route_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    route = db.query(MapRoute).filter(MapRoute.id == route_id, MapRoute.user_id == current_user.id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Маршрут не найден")
    db.delete(route)
    db.commit()
    return None