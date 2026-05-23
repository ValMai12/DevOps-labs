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

---

## Application

mywebapp is a simple notes service.

Each note has:

- id
- title
- content
- created_at

---

## API

### GET /

Returns an HTML page with the list of available business endpoints.

### GET /health/alive

Always returns:

```text
OK
GET /health/ready
Returns HTTP 200 if the application can connect to the database.
GET /notes
Returns list of notes.
Supports:
text/html
application/json
POST /notes
Creates a new note.
Example JSON body:
{
  "title": "My note",
  "content": "Hello"
}
GET /notes/<id>
Returns full note information.
Supports:
text/html
application/json
Local Development
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
Virtual Machine
The application was tested on:
Ubuntu Server 26.04 ARM64
UTM virtual machine on Apple Silicon MacBook
Recommended VM configuration:
1 CPU core
4 GB RAM
20 GB disk
Recommended OS:
Ubuntu Server 24.04 LTS
VM Login
Login user:
student
The deployment script creates additional users:
teacher
operator
app
Default password for teacher and operator:
12345678
Clone Repository
git clone https://github.com/ValMai12/DevOps-labs.git
cd DevOps-labs/mywebapp
git checkout lab1
Run Deployment
sudo ./deploy/install.sh
Verify Deployment
systemctl status mywebapp
systemctl status nginx
curl http://127.0.0.1/
curl http://127.0.0.1/notes
curl -H "Accept: application/json" http://127.0.0.1/notes
Create Note
curl -X POST http://127.0.0.1/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test note","content":"Hello"}'
Deployment Files
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
The deployment script also creates:
/home/student/gradebook
with value:
12
Repository
Repository URL:
https://github.com/ValMai12/DevOps-labs