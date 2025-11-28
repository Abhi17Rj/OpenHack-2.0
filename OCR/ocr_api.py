import io
import base64
import json
import re
from typing import Optional, Dict, Any

from fastapi import FastAPI, File, UploadFile, HTTPException, Query
from fastapi.responses import JSONResponse
from PIL import Image
import pytesseract
import requests

app = FastAPI(title="BusinessCardExtractor-Local", version="1.0")

# Ollama endpoint
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "llama3.2-vision"

# STRICT JSON prompt
LLM_PROMPT = """
You are analyzing a business card image.
Return ONLY a JSON object with EXACTLY these keys:
name, m_no, mail, company_name, city, country.

Rules:
- Values must be either string or null.
- If a value cannot be found, set it to null.
- DO NOT add any explanation.
- DO NOT wrap JSON in markdown.
Example:
{"name":"Aman Sharma","m_no":"02228040912","mail":"aman@yahoo.com","company_name":"Company Name","city":"Vadodara","country":"India"}
"""

# Regex
EMAIL_RE = re.compile(r'[\w\.-]+@[\w\.-]+\.\w+')
PHONE_RE = re.compile(r'(\+?\d[\d\-\s\(\)]{6,}\d)')
URL_RE = re.compile(r'(https?://\S+|www\.\S+|\S+\.(com|co|in|net|org|io))', re.I)

CITY_LIST = {
    "mumbai","delhi","chennai","kolkata","bengaluru","bangalore","hyderabad",
    "pune","vadodara","surat","ahmedabad","jaipur","coimbatore","madurai"
}

def normalize_phone(p: str) -> str:
    return re.sub(r'[^\d\+]', '', p)

def heuristic_extract(text: str) -> Dict[str, Optional[str]]:
    """Fallback for speed when LLM not available."""
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]

    emails = EMAIL_RE.findall(text)
    mail = emails[0] if emails else None

    phones = PHONE_RE.findall(text)
    m_no = None
    if phones:
        cleaned = [normalize_phone(p) for p in phones]
        cleaned = [c for c in cleaned if len(re.sub(r'\D','',c)) >= 7]
        m_no = cleaned[0] if cleaned else None

    name = None
    for ln in lines[:5]:
        if EMAIL_RE.search(ln) or PHONE_RE.search(ln) or URL_RE.search(ln):
            continue
        name = ln.title()
        break

    company = None
    for ln in lines:
        if "company" in ln.lower() or "ltd" in ln.lower():
            company = ln.title()
            break

    city = None
    for ln in lines:
        for c in CITY_LIST:
            if c in ln.lower():
                city = c.title()
                break

    country = "India" if city else None

    return {
        "name": name,
        "m_no": m_no,
        "mail": mail,
        "company_name": company,
        "city": city,
        "country": country
    }

def call_llama_vision(image_bytes: bytes) -> Optional[Dict[str,Any]]:
    """Call local llama3.2-vision (Ollama)."""
    try:
        b64 = base64.b64encode(image_bytes).decode()

        payload = {
            "model": MODEL_NAME,
            "prompt": LLM_PROMPT,
            "images": [b64],
            "stream": False
        }

        resp = requests.post(OLLAMA_URL, json=payload, timeout=40)
        resp.raise_for_status()
    except Exception:
        return None

    try:
        data = resp.json()
        content = data.get("response", "").strip()

        start = content.find("{")
        end = content.rfind("}") + 1

        if start != -1 and end != -1:
            return json.loads(content[start:end])

    except Exception:
        return None

    return None

@app.post("/extract")
async def extract(
    file: UploadFile = File(...),
    mode: str = Query("auto", pattern="^(auto|llm|local)$")
):
    if not file.content_type.startswith("image/"):
        print(file)
        raise HTTPException(status_code=400, detail="Please upload an image.")

    print(file)
    contents = await file.read()
    print("yes")

    try:
        img = Image.open(io.BytesIO(contents)).convert("RGB")
    except:
        raise HTTPException(status_code=400, detail="Invalid image file.")

    # Always OCR for fallback
    try:
        text = pytesseract.image_to_string(img, lang="eng")
    except:
        text = ""

    # LLM mode
    if mode in ("llm", "auto"):
        llm_res = call_llama_vision(contents)
        if llm_res:
            # Ensure JSON contains exactly required keys
            out = {}
            for k in ["name","m_no","mail","company_name","city","country"]:
                val = llm_res.get(k)
                out[k] = val if val not in ("", None) else None
            return JSONResponse(content=out)

        if mode == "llm":
            raise HTTPException(status_code=502, detail="Local LLM error.")

    # Fallback to local OCR
    res = heuristic_extract(text)
    out = {k: (res.get(k) or None) for k in ["name","m_no","mail","company_name","city","country"]}
    return JSONResponse(content=out)
