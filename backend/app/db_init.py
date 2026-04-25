from app.database import engine, Base
from app.models import User  # обязательно, чтобы модель была загружена

def init():
    print("Создаю таблицы...")
    Base.metadata.create_all(bind=engine)
    print("Готово! Таблицы созданы.")

if __name__ == "__main__":
    init()