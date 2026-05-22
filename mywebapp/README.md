# mywebapp

Laboratory work 1: Web service deployment with automation.

## Variant

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

## Application

mywebapp is a simple notes service.

Each note has:

- id
- title
- content
- created_at

## API

### GET /

Returns an HTML page with the list of available business endpoints.

### GET /health/alive

Always returns:

```text
OK

GET /health/ready
Returns OK with HTTP 200 if the application can connect to the database.

GET /notes
Returns list of notes.

Supports:
text/html
application/json

POST /notes
Creates a new note.

JSON example:
{
  "title": "My note",
  "content": "Hello"
}
GET /notes/<id>
Returns full note information.
Supports:
text/html
application/json
Local development

Install dependencies:
pip install -r requirements.txt

Run database migration:
python3 migrate.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp

Run application:
python3 app.py \
  --db-user mywebapp \
  --db-password mypassword \
  --db-name mywebapp

Application listens on:
127.0.0.1:3000
Deployment

Recommended OS:
Ubuntu Server 24.04 LTS

Recommended VM resources:
1 CPU
2 GB RAM
10 GB disk
Deployment files:
deploy/install.sh
deploy/mywebapp.service
deploy/mywebapp.socket
deploy/mywebapp.nginx

Run deployment script:
sudo ./deploy/install.sh
Linux users
The deployment script creates:
student
teacher
operator
app

Default password for teacher and operator:
12345678
The deployment script also creates:
/home/student/gradebook
with value:
12

Testing
Check application through nginx:
curl http://127.0.0.1/
curl http://127.0.0.1/notes
curl -H "Accept: application/json" http://127.0.0.1/notes

Create note:
curl -X POST http://127.0.0.1/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test note","content":"Hello"}'

Check service status:
systemctl status mywebapp
Check nginx status:
systemctl status nginx