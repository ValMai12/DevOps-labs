# mywebapp

Laboratory work №1: Web service deployment with automation.

---

# Variant

N = 12

Calculations:

- V2 = (12 % 2) + 1 = 1
- V3 = (12 % 3) + 1 = 1
- V5 = (12 % 5) + 1 = 3

Result:

- Web application: Notes Service
- Configuration method: command line arguments
- Database: MariaDB
- Application port: 3000

---

# Application

mywebapp is a simple notes service.

Each note contains:

- id
- title
- content
- created_at

---

# API

## GET /

Returns an HTML page with the list of available business endpoints.

---

## GET /health/alive

Always returns:

```text
OK
```

with HTTP 200.


GET /health/ready
Returns:
OK
with HTTP 200 if the application can connect to the database.
Returns HTTP 500 if the database connection is unavailable.


GET /notes
Returns the list of notes.
Supported formats:
text/html
application/json
Example JSON response:
[
  {
    "id": 1,
    "title": "First note"
  }
]


POST /notes
Creates a new note.
Example request:
{
  "title": "My note",
  "content": "Hello"
}
Example response:
{
  "id": 1,
  "title": "My note",
  "content": "Hello"
}


GET /notes/<id>
Returns full note information.
Supported formats:
text/html
application/json
Example JSON response:
{
  "id": 1,
  "title": "My note",
  "content": "Hello",
  "created_at": "2026-05-22 18:10:14"
}


Local Development

Install dependencies
pip install -r requirements.txt

Run database migration
python3 migrate.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp

Run application
python3 app.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp
Application listens on:
127.0.0.1:3000



Deployment

Virtual Machine

The application was tested on:
Ubuntu Server 26.04 ARM64
UTM virtual machine
Apple Silicon MacBook

Recommended VM configuration:
1 CPU core
4 GB RAM
20 GB disk

Recommended OS:
Ubuntu Server 24.04 LTS


VM Login

Main user:
student

The deployment script creates additional users:
teacher
operator
app

Default password for:
teacher
operator
12345678
Passwords must be changed after the first login.

Clone Repository
git clone https://github.com/ValMai12/DevOps-labs.git
cd DevOps-labs/mywebapp
git checkout lab1

Run Deployment
Run from the mywebapp directory:
sudo ./deploy/install.sh

The deployment script automatically:
installs required packages
creates Linux users
configures MariaDB
creates the database
installs Python dependencies
installs systemd service
installs systemd socket
configures nginx reverse proxy
creates /home/student/gradebook
starts all required services


Verify Deployment

Check application service:
systemctl status mywebapp

Check nginx:
systemctl status nginx

Check root endpoint:
curl http://127.0.0.1/

Check notes endpoint:
curl http://127.0.0.1/notes

Check JSON response:
curl -H "Accept: application/json" http://127.0.0.1/notes

Create note:
curl -X POST http://127.0.0.1/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test note","content":"Hello"}'


Reverse Proxy
Nginx works as a reverse proxy.
Publicly available endpoints:
/
/notes
/notes/<id>
Health endpoints are not exposed through nginx.


Database
Database:
MariaDB
Database listens only on localhost.


Systemd

Application files:
deploy/mywebapp.service
deploy/mywebapp.socket

The application:
runs as Linux user app
automatically performs database migration before startup
uses systemd socket activation
runs through Gunicorn


Deployment Files

Project deployment files:
deploy/install.sh
deploy/mywebapp.service
deploy/mywebapp.socket
deploy/mywebapp.nginx


Linux Users

The deployment script creates:
student
teacher
operator
app
Operator user is allowed to execute only:
status/restart/start/stop mywebapp
reload nginx


Gradebook

The deployment script creates:
/home/student/gradebook
File content:
12


Repository

Repository URL:
https://github.com/ValMai12/DevOps-labs