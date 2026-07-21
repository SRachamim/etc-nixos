#!/usr/bin/env python3
"""Fetch i24news Hebrew breaking news and output TSV: title\tlink\tsource\tepoch."""

import json
import sys
import urllib.request
from datetime import datetime, timezone

API_URL = "https://api.i24news.tv/v2/he/news"
SOURCE = "i24"


def fetch_news():
    """Fetch headlines from i24news Hebrew API."""
    try:
        req = urllib.request.Request(API_URL, headers={"User-Agent": "sketchybar-news/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except Exception:
        return

    items = data if isinstance(data, list) else data.get("items", data.get("data", []))

    for item in items:
        if not isinstance(item, dict):
            continue
        title = (item.get("title") or "").strip()
        if not title:
            continue

        item_id = item.get("id", "")
        link = f"https://www.i24news.tv/he/news"
        if item_id:
            link = f"https://www.i24news.tv/he/news/{item_id}"

        started_at = item.get("startedAt", "")
        epoch = ""
        if started_at:
            try:
                dt = datetime.fromisoformat(started_at.replace("Z", "+00:00"))
                epoch = str(int(dt.timestamp()))
            except (ValueError, TypeError):
                pass

        clean_title = title.replace("\t", " ").replace("\n", " ").replace("\r", "")
        print(f"{clean_title}\t{link}\t{SOURCE}\t{epoch}")


if __name__ == "__main__":
    fetch_news()
