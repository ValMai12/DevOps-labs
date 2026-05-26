# mywebapp

Лабораторна робота №4  
IaC. Terraform. Ansible

ПІБ: Маєвська Валерія Олександрівна ІМ-41

---

# Мета роботи

Метою роботи є практичне засвоєння принципів декларативного керування інфраструктурою та конфігурацією за допомогою Terraform та Ansible.

У роботі реалізовано розгортання розподіленого веб-застосунку, який складається з:

- worker VM
  - nginx reverse proxy
  - Flask веб-застосунок
- db VM
  - MariaDB база даних

---

# Варіант

N = 12

Обчислення:

- V2 = (12 % 2) + 1 = 1
- V3 = (12 % 3) + 1 = 1
- V5 = (12 % 5) + 1 = 3

Результат:

- Веб-застосунок: Notes Service
- Спосіб конфігурації: command line arguments
- База даних: MariaDB
- Порт застосунку: 3000

---

# Архітектура системи

```text
client
   |
   v
+--------------------------------------+
| VM1 (worker)                         |
|--------------------------------------|
| nginx reverse proxy                  |
| Flask application (Gunicorn)         |
+--------------------------------------+
                |
                v
+--------------------------------------+
| VM2 (db)                             |
|--------------------------------------|
| MariaDB                              |
+--------------------------------------+
```

---

# Мережева конфігурація

## Worker VM

| Компонент | Адреса | Порт |
|---|---|---|
| nginx | 0.0.0.0 | 80 |
| web application | 127.0.0.1 | 3000 |

## Database VM

| Компонент | Адреса | Порт |
|---|---|---|
| MariaDB | VM IP | 3306 |

---

# Використані технології

- Terraform
- Ansible
- libvirt
- QEMU/KVM
- Ubuntu 24.04 ARM
- MariaDB
- nginx
- Flask
- Gunicorn

---

# Terraform Provisioning

Інфраструктура створюється за допомогою Terraform.

Terraform створює:

- libvirt network
- storage pool
- Ubuntu cloud image
- cloud-init disks
- worker VM
- db VM

Структура Terraform:

```text
terraform/
├── cloud-init.yml
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── .terraform.lock.hcl
```

---

# Cloud-init

Cloud-init використовується для:

- створення користувача ansible
- налаштування SSH доступу
- налаштування passwordless sudo
- встановлення базових пакетів

Приклад:

```yaml
users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
```

---

# Configuration Management (Ansible)

Ansible використовується замість Bash-скриптів.

Inventory файл:

```text
ansible/inventory/hosts.ini
```

Inventory групи:

```ini
[workers]
worker ansible_host=192.168.64.14 ansible_user=ansible

[db]
database ansible_host=192.168.64.15 ansible_user=ansible
```

---

# Ansible Roles

## common

Налаштовує:

- спільні пакети
- користувача teacher
- файл gradebook

## db

Налаштовує:

- MariaDB
- створення бази даних
- створення користувача БД
- мережеву конфігурацію MariaDB

## worker

Налаштовує:

- nginx
- Flask застосунок
- Gunicorn
- systemd service
- користувача operator
- sudo permissions

---

# Використання templates

У проєкті використовуються Ansible templates:

```text
ansible/roles/db/templates/50-server.cnf.j2
ansible/roles/worker/templates/mywebapp.nginx.j2
ansible/roles/worker/templates/mywebapp.service.j2
ansible/roles/worker/templates/operator-sudoers.j2
```

Динамічні параметри підставляються через Jinja2:

```jinja2
{{ db_ip }}
{{ worker_ip }}
{{ db_user }}
{{ db_password }}
```

---

# Користувачі системи

| Користувач | Призначення | Права |
|---|---|---|
| ansible | автоматичне налаштування | passwordless sudo |
| teacher | перевірка роботи | sudo з паролем |
| app | запуск застосунку | мінімальні права |
| operator | керування сервісами | обмежений sudo |

Паролі за замовчуванням:

```text
teacher: 12345678
operator: 12345678
```

---

# Права користувача operator

Користувач operator має право виконувати лише:

- запуск застосунку
- зупинку застосунку
- перезапуск застосунку
- перегляд статусу застосунку
- reload nginx

Приклад:

```bash
sudo systemctl restart mywebapp
sudo systemctl reload nginx
```

---

# Gradebook

Автоматично створюється файл:

```text
/home/student/gradebook
```

Вміст файлу:

```text
12
```

---

# Health Checks

Застосунок реалізує:

| Endpoint | Призначення |
|---|---|
| /health/alive | перевірка доступності застосунку |
| /health/ready | перевірка підключення до БД |

Перевірка:

```bash
curl http://192.168.64.14/health/alive
curl http://192.168.64.14/health/ready
```

Результат:

```text
OK
OK
```

---

# Перевірка роботи застосунку

Головна сторінка:

```bash
curl http://192.168.64.14/
```

Список нотаток:

```bash
curl http://192.168.64.14/notes
```

---

# Ідемпотентність

Повторний запуск Ansible playbook не виконує змін:

```text
PLAY RECAP

database : changed=0 failed=0
worker   : changed=0 failed=0
```

Це підтверджує ідемпотентність конфігурації.

---

# Запуск Terraform

Ініціалізація Terraform:

```bash
terraform -chdir=terraform init
```

Форматування Terraform:

```bash
terraform -chdir=terraform fmt
```

Перевірка конфігурації:

```bash
terraform -chdir=terraform validate
```

Створення інфраструктури:

```bash
sudo terraform -chdir=terraform apply
```

---

# Запуск Ansible

Встановлення collection:

```bash
ansible-galaxy collection install community.mysql
```

Запуск playbook:

```bash
ansible-playbook \
  -i ansible/inventory/hosts.ini \
  ansible/playbook.yml \
  --ask-pass \
  --ask-become-pass
```

---

# Структура проєкту

```text
.
├── ansible
│   ├── group_vars
│   ├── inventory
│   ├── playbook.yml
│   └── roles
├── terraform
├── mywebapp
└── README.md
```

---

# Результат роботи

У результаті виконання лабораторної роботи було реалізовано:

- Infrastructure as Code за допомогою Terraform
- Configuration Management за допомогою Ansible
- автоматичне розгортання двох VM
- reverse proxy архітектуру
- systemd service для застосунку
- health checks
- role-based access control
- idempotent configuration management
- автоматизоване розгортання веб-застосунку та бази даних