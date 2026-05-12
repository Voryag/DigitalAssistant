import requests
import json
import re
from datetime import datetime, timedelta

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen2.5:3b"


def parse_user_request(text: str) -> dict:
    today = datetime.now().strftime("%Y-%m-%d")
    tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")

    prompt = f"""Ты — помощник для создания задач, заметок и событий календаря. Проанализируй запрос и верни ТОЛЬКО JSON.

Сегодня: {today}
Завтра: {tomorrow}

Правила:
- intent: "task" (дело/действие), "note" (идея/мысль), "calendar" (встреча/событие/праздник/дедлайн)
- title: краткий заголовок
- content: описание (если есть)
- project: проект ("работа", "дом", "учёба", "БСК" или пусто)
- tags: метка (#срочно, #важно, #баг или пусто)
- priority: "easy", "medium", "hard"
- due_date: дата завершения задачи в формате YYYY-MM-DD (если указана)
- start_time: время начала события в формате HH:MM (ТОЛЬКО для calendar)
- end_time: время окончания в формате HH:MM (ТОЛЬКО для calendar, по умолчанию +1 час)

Примеры:
Запрос: "Срочно купить хлеб завтра"
Ответ: {{"intent":"task","title":"Купить хлеб","content":"","project":"дом","tags":"#срочно","priority":"hard","due_date":"{tomorrow}","start_time":"","end_time":""}}

Запрос: "Встреча с командой в пятницу в 15:00"
Ответ: {{"intent":"calendar","title":"Встреча с командой","content":"","project":"работа","tags":"","priority":"medium","due_date":"","start_time":"15:00","end_time":"16:00"}}

Запрос: "День рождения мамы 20 июня, не забыть поздравить"
Ответ: {{"intent":"calendar","title":"День рождения мамы","content":"Не забыть поздравить","project":"","tags":"#важно","priority":"hard","due_date":"","start_time":"09:00","end_time":"10:00"}}

Запрос: "Записаться к врачу на послезавтра на 11 утра"
Ответ: {{"intent":"calendar","title":"Запись к врачу","content":"","project":"","tags":"","priority":"medium","due_date":"","start_time":"11:00","end_time":"12:00"}}

Запрос: "Созвон с заказчиком завтра в 14:00 по поводу проекта БСК"
Ответ: {{"intent":"calendar","title":"Созвон с заказчиком","content":"По поводу проекта БСК","project":"БСК","tags":"#важно","priority":"hard","due_date":"","start_time":"14:00","end_time":"15:00"}}

Запрос: "Идея для стартапа"
Ответ: {{"intent":"note","title":"Идея для стартапа","content":"","project":"","tags":"","priority":"medium","due_date":"","start_time":"","end_time":""}}

Запрос: "{text}"
JSON:"""

    try:
        session = requests.Session()
        session.headers.update({"Content-Type": "application/json; charset=utf-8"})

        response = session.post(
            OLLAMA_URL,
            json={
                "model": MODEL,
                "prompt": prompt,
                "stream": False,
                "format": "json",
                "options": {"temperature": 0.1}
            },
            timeout=60
        )
        response.raise_for_status()
        data = response.json()

        raw = data["response"].strip()
        print(f"OLLAMA: {raw}")

        match = re.search(r'\{[^{}]*\}', raw)
        if match:
            result = json.loads(match.group())
            return {
                "intent": result.get("intent", "note"),
                "title": result.get("title", text[:100]),
                "content": result.get("content", ""),
                "project": result.get("project", ""),
                "tags": result.get("tags", ""),
                "priority": result.get("priority", "medium"),
                "due_date": result.get("due_date", ""),
                "start_time": result.get("start_time", ""),
                "end_time": result.get("end_time", ""),
            }

        return _default_response(text)

    except Exception as e:
        print(f"ERROR: {e}")
        return _default_response(text)


def _default_response(text: str) -> dict:
    return {
        "intent": "note",
        "title": text[:100],
        "content": "",
        "project": "",
        "tags": "",
        "priority": "medium",
        "due_date": "",
        "start_time": "",
        "end_time": "",
    }