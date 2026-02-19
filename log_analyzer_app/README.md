# Simple FastAPI + Streamlit Log Analyzer

This project provides a minimal and secure starter app:

- **Streamlit UI** for uploading application log files.
- **FastAPI backend** that receives logs and calls OpenAI.
- Suggested root cause and remediation steps are returned to UI.

## Folder structure

```text
log_analyzer_app/
├── backend/
│   └── app/
│       ├── __init__.py
│       ├── config.py
│       └── main.py
├── frontend/
│   └── streamlit_app.py
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
```

## Security basics included

- OpenAI key is loaded from environment variables (`OPENAI_API_KEY`) only.
- `.env` is ignored by git.
- Backend validates max upload size (`MAX_LOG_SIZE_BYTES`).
- Backend accepts only UTF-8 text logs.
- Frontend never receives or stores OpenAI key.

## Setup

```bash
cd log_analyzer_app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# edit .env and add real OPENAI_API_KEY
```

## Run backend

```bash
cd log_analyzer_app
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Run frontend

```bash
cd log_analyzer_app
streamlit run frontend/streamlit_app.py
```

Open http://localhost:8501, upload a log file, and click **Analyze log**.
