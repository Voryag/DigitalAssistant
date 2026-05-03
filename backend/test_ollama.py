import requests
import json

url = "http://localhost:11434/api/generate"

# Кодируем в UTF-8 ЯВНО
prompt_text = """Ты — анализатор запросов. Определи категорию и теги. Ответь ТОЛЬКО JSON.

Категории: task, note, calendar, maps, sheet.

Примеры:
"Купить хлеб завтра" -> {{"intent":"task","tags":["покупки"]}}
"Встреча с командой в 15" -> {{"intent":"calendar","tags":["работа"]}}
"Идея для проекта" -> {{"intent":"note","tags":["идеи"]}}"
prompt_bytes = prompt_text.encode("utf-8") 

А теперь ответь на следующий запрос: Купить завтра хлеба домой"""

body = {
    "model": "qwen2.5:3b",
    "prompt": prompt_text,  # передаём строку, не байты
    "stream": False,
    "options": {"temperature": 0.1}
}

# Отправляем с явным заголовком кодировки
headers = {"Content-Type": "application/json; charset=utf-8"}
response = requests.post(url, json=body, headers=headers, timeout=30)

print("Status:", response.status_code)
print("Response:", response.text)

data = response.json()
print("Ответ:", data.get("response", "НЕТ"))