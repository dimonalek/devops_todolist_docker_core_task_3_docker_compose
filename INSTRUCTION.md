# Docker Compose Instructions

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Docker Compose](https://docs.docker.com/compose/install/) installed (included with Docker Desktop)

---

## Project Overview

This project runs two containers managed by Docker Compose:

| Service | Description | Port |
|---------|-------------|------|
| `db`    | MySQL 8 database with a persistent volume | `3306` |
| `app`   | Django Todolist web application | `8080` |

Todos are stored in the MySQL database. The data is persisted in a named Docker volume (`mysql_data`) so it survives container restarts and re-creations.

---

## How to Build and Start the Containers

From the project root directory (where `docker-compose.yml` lives), run:

```bash
docker-compose up --build
```

- `--build` forces Docker to (re)build the images before starting containers.
- The `db` service will start first. The `app` service waits until the MySQL healthcheck passes before it starts.
- Database migrations are applied automatically when the `app` container starts.
- The application will be accessible at **http://localhost:8080**.

To start the containers **in the background** (detached mode):

```bash
docker-compose up --build -d
```

---

## How to Stop the Containers

To stop the running containers **without** removing them:

```bash
docker-compose stop
```

To stop **and remove** the containers (the volume and its data are preserved):

```bash
docker-compose down
```

To stop and remove the containers **and** delete all data (volumes included):

```bash
docker-compose down -v
```

> ⚠️ Using `-v` will permanently delete all stored todos.

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
| `docker-compose exec db mysql -u app_user -p app_db` | Open a MySQL shell |

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
