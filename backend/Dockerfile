FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 TZ=Europe/Istanbul \
    ORTAM=production LOG_FORMAT=json
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN useradd --create-home uygulama && mkdir -p uploads && chown -R uygulama /app && chmod +x docker-entrypoint.sh
USER uygulama

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request,os;urllib.request.urlopen(f'http://127.0.0.1:{os.environ.get(\"PORT\",\"8000\")}/health',timeout=4)"
# Varsayılan: migration + gunicorn (web). Worker için: docker run <imaj> python worker.py
ENTRYPOINT ["./docker-entrypoint.sh"]
