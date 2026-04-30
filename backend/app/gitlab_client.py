import httpx
from app.config import GITLAB_TOKEN, GITLAB_PROJECT_ID, GITLAB_API_URL

async def create_gitlab_issue(title: str, description: str = None, labels: list[str] = None) -> dict:
    url = f"{GITLAB_API_URL}/projects/{GITLAB_PROJECT_ID}/issues"

    headers = {
        "PRIVATE-TOKEN": GITLAB_TOKEN,
        "Content-Type": "application/json"
    }

    body = {
        "title": title,
        "description": description or "",
        "labels": ",".join(labels) if labels else ""
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(url, json=body, headers=headers)
        response.raise_for_status()
        data = response.json()

        return {
            "gitlab_id": data["id"],
            "gitlab_iid": data["iid"],
            "gitlab_url": data["web_url"]
        }