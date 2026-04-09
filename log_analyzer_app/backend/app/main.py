from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI

from .config import get_settings

app = FastAPI(title="Log Suggestion API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8501"],
    allow_credentials=False,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/analyze-log")
async def analyze_log(file: UploadFile = File(...)) -> dict[str, str]:
    settings = get_settings()

    raw_content = await file.read(settings.max_log_size_bytes + 1)
    if len(raw_content) > settings.max_log_size_bytes:
        raise HTTPException(
            status_code=413,
            detail=(
                f"File too large. Limit is {settings.max_log_size_bytes} bytes. "
                "Upload a smaller log file."
            ),
        )

    if not raw_content.strip():
        raise HTTPException(status_code=400, detail="Uploaded log file is empty.")

    try:
        log_text = raw_content.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise HTTPException(status_code=400, detail="Only UTF-8 text log files are supported.") from exc

    prompt = (
        "You are a production support assistant. Analyze the following application log and return:\n"
        "1) probable root cause\n"
        "2) short explanation\n"
        "3) concrete remediation steps\n"
        "4) prevention tips\n\n"
        f"Log:\n{log_text}"
    )

    client = OpenAI(api_key=settings.openai_api_key)

    try:
        response = client.responses.create(
            model=settings.openai_model,
            input=prompt,
        )
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Failed to get response from LLM provider.") from exc

    result = response.output_text.strip()
    if not result:
        raise HTTPException(status_code=502, detail="LLM returned an empty response.")

    return {"suggested_solution": result}
