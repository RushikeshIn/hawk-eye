# Slim runtime base (~150MB vs ~1.2GB for python:3)
FROM python:3.12-slim-bookworm

WORKDIR /app

# Runtime system deps only (OCR + video). --no-install-recommends keeps apt layer small.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        tesseract-ocr \
        libglib2.0-0 \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt setup.py setup.cfg MANIFEST.in readme.md LICENSE CITATION.cff fingerprint.yml ./
COPY hawk_scanner ./hawk_scanner/
COPY assets ./assets/

# headless OpenCV drops GUI libs (~200–400MB). Install deps once, then package without --no-deps duplication.
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && sed 's/^opencv-python$/opencv-python-headless/' requirements.txt > requirements.docker.txt \
    && pip install --no-cache-dir -r requirements.docker.txt \
    && pip install --no-cache-dir --no-deps .

ENTRYPOINT ["hawk_scanner"]
