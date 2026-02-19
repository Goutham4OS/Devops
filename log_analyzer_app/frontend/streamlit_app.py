import requests
import streamlit as st

BACKEND_URL = st.secrets.get("BACKEND_URL", "http://localhost:8000")

st.set_page_config(page_title="Log Analyzer", page_icon="🛠️")
st.title("🛠️ Application Log Analyzer")
st.write("Upload a UTF-8 log file and get suggested fixes from the AI backend.")

uploaded_file = st.file_uploader("Upload application log", type=["log", "txt"])

if st.button("Analyze log", type="primary"):
    if uploaded_file is None:
        st.warning("Please upload a log file first.")
    else:
        with st.spinner("Analyzing logs..."):
            files = {
                "file": (uploaded_file.name, uploaded_file.getvalue(), uploaded_file.type or "text/plain")
            }
            try:
                response = requests.post(f"{BACKEND_URL}/analyze-log", files=files, timeout=90)
            except requests.RequestException:
                st.error("Could not connect to backend API. Ensure FastAPI is running.")
            else:
                if response.ok:
                    st.success("Analysis completed")
                    st.markdown(response.json().get("suggested_solution", "No suggestion received."))
                else:
                    detail = response.json().get("detail", "Unknown backend error")
                    st.error(f"Backend error: {detail}")
