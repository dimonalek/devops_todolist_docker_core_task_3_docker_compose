# Docker Compose Instructions

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Docker Compose](https://docs.docker.com/compose/install/) installed (included with Docker Desktop)

---

## Project Overview

This project runs two containers managed by Docker Compose:

| Service | Description | Port |
|---------|-------------|------|
| `db`    | MySQL 8 database (official `mysql:8` image) with a persistent volume | `3306` |
| `app`   | Django Todolist web application | `8080` |

Todos are stored in the MySQL database. The data is persisted in a named Docker volume (`mysql_data`) so it survives container restarts and re-creations.

### How startup sequencing works

The `db` service exposes a `healthcheck` that polls `mysqladmin ping` every 10 seconds (up to 10 retries). The `app` service declares `depends_on: - db`, which ensures Docker starts the `db` container before `app`.

> ⚠️ **Note:** The simple `depends_on` list form does **not** wait for MySQL to be ready — only for the container to start. The real readiness gate is `wait_for_db.sh` inside the app container, which polls `mysqladmin ping` in a retry loop and only proceeds to run migrations and start the server once MySQL accepts connections. This approach works reliably across all Compose versions.

---

## How to Build and Start the Containers

From the project root directory (where `docker-compose.yml` lives), run:

```bash
docker-compose up --build
```

- `--build` forces Docker to (re)build the app image before starting.
- The `db` service starts first. `wait_for_db.sh` inside the app container waits until MySQL accepts connections.
- Database migrations run automatically once MySQL is ready.
- The application will be accessible at:
  - **Landing page:** http://localhost:8080
  - **REST API:** http://localhost:8080/api/

To start the containers **in the background** (detached mode):

```bash
docker-compose up --build -d
```

---

## How to Stop the Containers

Stop the running containers **without** removing them:

```bash
docker-compose stop
```

Stop **and remove** the containers (volume and data are preserved):

```bash
docker-compose down
```

Stop and remove the containers **and** delete all stored data (volumes included):

```bash
docker-compose down -v
```

> ⚠️ Using `-v` will permanently delete all stored todos.

---

## Running the Application Locally (without Docker)

You will need Python 3.8+ and a running MySQL instance. Configure MySQL with a database and user matching the settings below, then:

```bash
# 1. Create and activate a virtual environment (recommended)
python -m venv venv
source venv/bin/activate        # Linux / macOS
venv\Scripts\activate           # Windows PowerShell

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set environment variables for your local MySQL connection
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_DATABASE=app_db
export MYSQL_USER=app_user
export MYSQL_PASSWORD=1234

# 4. Apply database migrations
python manage.py migrate

# 5. Start the development server (Django's default port is 8000)
python manage.py runserver
```

The application will be accessible at:
- **Landing page:** http://localhost:8000
- **REST API:** http://localhost:8000/api/

> 💡 To use a different port locally, run `python manage.py runserver 0.0.0.0:8080` and visit http://localhost:8080 instead.

---

## Viewing Logs

View logs for all services:

```bash
docker-compose logs -f
```

View logs for a specific service (e.g. the app):

```bash
docker-compose logs -f app
```

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `docker-compose ps` | List running containers |
| `docker-compose restart app` | Restart the app container |
| `docker-compose exec app python manage.py createsuperuser` | Create a Django superuser |
| `docker-compose exec db mysql -u app_user -pYOURPASSWORD app_db` | Open a MySQL shell (no space between `-p` and the password) |

---

## Environment Variables

The following environment variables are used by the `app` service and can be overridden if needed:

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_HOST` | `db` | Hostname of the MySQL service |
| `MYSQL_PORT` | `3306` | MySQL port |
| `MYSQL_DATABASE` | `app_db` | Database name |
| `MYSQL_USER` | `app_user` | Database user |
| `MYSQL_PASSWORD` | `1234` | Database password |
