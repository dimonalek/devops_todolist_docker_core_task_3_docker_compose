# Stage 1: Build Stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} as builder

# Set the working directory
WORKDIR /app
COPY . .

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY --from=builder /app .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy and prepare the DB-wait / entrypoint script
COPY wait_for_db.sh /wait_for_db.sh
RUN chmod +x /wait_for_db.sh

EXPOSE 8080

# Wait for MySQL, run migrations, then start the server
ENTRYPOINT ["sh", "/wait_for_db.sh"]
