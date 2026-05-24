# mywebapp

> Laboratory work №1: Web service deployment with automation.

---

# Student Information

| Field | Value |
|---|---|
| Student | Маєвська Валерія Олександрівна |
| Group | ІМ-41 |
| Variant Number | 12 |

---

# Variant Calculation

## Calculations

```text
V2 = (12 % 2) + 1 = 1
V3 = (12 % 3) + 1 = 1
V5 = (12 % 5) + 1 = 3
```

## Result

| Parameter | Value |
|---|---|
| Web application | Notes Service |
| Configuration method | Command line arguments |
| Database | MariaDB |
| Application port | 3000 |

---

# Application

`mywebapp` is a simple notes service.

Each note contains:

- `id`
- `title`
- `content`
- `created_at`

---

# API

## `GET /`

Returns an HTML page with the list of available business endpoints.

---

## `GET /health/alive`

Always returns:

```text
OK
```

with HTTP 200.

---

## `GET /health/ready`

Returns:

- `OK` with HTTP 200 if the application can connect to the database
- HTTP 500 if the database connection is unavailable

---

## `GET /notes`

Returns the list of notes.

### Supported formats

- `text/html`
- `application/json`

### Example JSON response

```json
[
  {
    "id": 1,
    "title": "First note"
  }
]
```

---

## `POST /notes`

Creates a new note.

### Example request

```json
{
  "title": "My note",
  "content": "Hello"
}
```

### Example response

```json
{
  "id": 1,
  "title": "My note",
  "content": "Hello"
}
```

---

## `GET /notes/<id>`

Returns full note information.

### Supported formats

- `text/html`
- `application/json`

### Example JSON response

```json
{
  "id": 1,
  "title": "My note",
  "content": "Hello",
  "created_at": "2026-05-22 18:10:14"
}
```

---

# Local Development

## Install dependencies

```bash
pip install -r requirements.txt
```

---

## Run database migration

```bash
python3 migrate.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp
```

---

## Run application

```bash
python3 app.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp
```

Application listens on:

```text
127.0.0.1:3000
```

---

# Deployment

# Virtual Machine

The application was tested on:

- Ubuntu Server 26.04 ARM64
- UTM virtual machine
- Apple Silicon MacBook

## Recommended VM configuration

| Resource | Value |
|---|---|
| CPU | 1 core |
| RAM | 4 GB |
| Disk | 20 GB |

## Recommended OS

```text
Ubuntu Server 24.04 LTS
```

---

# VM Login

## Main user

```text
student
```

The deployment script creates additional users:

- `teacher`
- `operator`
- `app`

## Default password

Default password for:

- `teacher`
- `operator`

```text
12345678
```

> Passwords must be changed after the first login.

---

# Clone Repository

```bash
git clone https://github.com/ValMai12/DevOps-labs.git
cd DevOps-labs/mywebapp
git checkout lab1
```

---

# Run Deployment

Run from the `mywebapp` directory:

```bash
sudo ./deploy/install.sh
```

## The deployment script automatically

- installs required packages
- creates Linux users
- configures MariaDB
- creates the database
- installs Python dependencies
- installs systemd service
- installs systemd socket
- configures nginx reverse proxy
- creates `/home/student/gradebook`
- starts all required services

---

# Verify Deployment

## Check application service

```bash
systemctl status mywebapp
```

---

## Check nginx

```bash
systemctl status nginx
```

---

## Check root endpoint

```bash
curl http://127.0.0.1/
```

---

## Check notes endpoint

```bash
curl http://127.0.0.1/notes
```

---

## Check JSON response

```bash
curl -H "Accept: application/json" http://127.0.0.1/notes
```

---

## Create note

```bash
curl -X POST http://127.0.0.1/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test note","content":"Hello"}'
```

---

# Reverse Proxy

Nginx works as a reverse proxy.

## Publicly available endpoints

- `/`
- `/notes`
- `/notes/<id>`

> Health endpoints are not exposed through nginx.

---

# Database

| Parameter | Value |
|---|---|
| Database | MariaDB |
| Access | localhost only |

---

# Systemd

## Application files

- `deploy/mywebapp.service`
- `deploy/mywebapp.socket`

## The application

- runs as Linux user `app`
- automatically performs database migration before startup
- uses systemd socket activation
- runs through Gunicorn

---

# Deployment Files

Project deployment files:

- `deploy/install.sh`
- `deploy/mywebapp.service`
- `deploy/mywebapp.socket`
- `deploy/mywebapp.nginx`

---

# Linux Users

The deployment script creates:

- `student`
- `teacher`
- `operator`
- `app`

## Operator permissions

Operator user is allowed to execute only:

- `status/restart/start/stop mywebapp`
- `reload nginx`

---

# Gradebook

The deployment script creates:

```text
/home/student/gradebook
```

## File content

```text
12
```

---

# Repository

Repository URL:

```text
https://github.com/ValMai12/DevOps-labs
```

# Docker Compose Deployment

The project can also be deployed using Docker Compose.

---

# Services

Docker Compose starts 3 containers:

- `web` — Flask + Gunicorn application
- `db` — MariaDB database
- `nginx` — reverse proxy

---

# Docker Network

Containers communicate using a dedicated Docker bridge network:

- `mywebapp_network`

---

# Persistent Storage

Database data is stored in a Docker volume:

- `mywebapp_db_data`

The data survives:

- container restart
- `docker compose down`
- system reboot

---

# Build and Run

Run from the `mywebapp` directory:

```bash
docker compose up --build
```

---

## Run in background

```bash
docker compose up -d
```

---

## Stop containers

```bash
docker compose down
```

---

# Verify Deployment

## Check running containers

```bash
docker compose ps
```

---

## Check root endpoint

```bash
curl http://localhost/
```

---

## Check notes endpoint

```bash
curl http://localhost/notes
```

---

## Check JSON response

```bash
curl -H "Accept: application/json" http://localhost/notes
```

---

## Create note

```bash
curl -X POST http://localhost/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Docker test","content":"Hello from Docker Compose"}'
```

---

# Docker Files

The Docker deployment uses:

- `Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- `nginx/mywebapp.conf`