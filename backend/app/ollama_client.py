import json
import re
import requests
from app.config import OLLAMA_URL, MODEL


OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen2.5:3b"


def parse_user_request(text: str) -> dict:
    prompt = f"""Ты — анализатор запросов. Определи категорию и теги. Ответь ТОЛЬКО JSON.

Категории: task, note, calendar, maps, sheet.

Примеры:
"Купить хлеб завтра" -> {{"intent":"task","tags":["покупки"]}}
"Встреча с командой в 15" -> {{"intent":"calendar","tags":["работа"]}}
"Идея для проекта" -> {{"intent":"note","tags":["идеи"]}}

prompt_bytes = prompt_text.encode("utf-8") 

Запрос: "{text}"
JSON:"""

    try:
        headers = {"Content-Type": "application/json; charset=utf-8"}
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": MODEL,
                "prompt": prompt,
                "stream": False,
                "format": "json",
                "options": {"temperature": 0.1}
            },
            headers=headers,
            timeout=60
        )
        response.raise_for_status()
        data = response.json()

        raw = data["response"].strip()
        print(f"OLLAMA: {raw}")

        match = re.search(r'\{[^{}]*\}', raw)
        if match:
            result = json.loads(match.group())
            return {"intent": result.get("intent", "note"), "tags": result.get("tags", [])}

        return {"intent": "note", "tags": []}

    except Exception as e:
        print(f"ERROR: {e}")
        return {"intent": "note", "tags": []}