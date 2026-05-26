# Лабораторна робота №3 — CI/CD

## Мета роботи

Метою даної лабораторної роботи є налаштування повного CI/CD pipeline для застосунку з Лабораторної роботи №1.

Pipeline включає:

- continuous integration
- автоматичне тестування
- збірку Docker image
- публікацію Docker image
- розгортання на віддаленій віртуальній машині
- verification-перевірку розгортання

---

# Посилання на репозиторій

GitHub repository:

https://github.com/ValMai12/DevOps-labs

Гілка лабораторної роботи №3:

https://github.com/ValMai12/DevOps-labs/tree/lab3

---

# Інфраструктура

## Runner VM

Self-hosted GitHub Actions runner:

- Ubuntu 24.04.3 LTS
- ARM64
- віртуальна машина UTM
- GitHub Actions self-hosted runner

## Target VM

Сервер для deployment:

- Ubuntu 24.04.3 LTS
- ARM64
- Docker
- nginx

---

# CI Pipeline

CI workflow виконує:

- встановлення Python-залежностей
- статичний аналіз коду через flake8
- запуск pytest

Файл workflow:

```text
.github/workflows/ci.yml
```

---

# Docker Build Pipeline

Build workflow:

- збирає Docker images
- публікує images у GitHub Container Registry
- підтримує ARM64 платформу

Опублікований image:

```text
ghcr.io/valmai12/devops-labs/mywebapp
```

Файл workflow:

```text
.github/workflows/build.yml
```

---

# Deployment Pipeline

Deployment workflow:

- копіює deployment scripts на target VM
- розгортає контейнер MariaDB
- розгортає контейнер вебзастосунку
- налаштовує nginx reverse proxy
- автоматично виконує verification deployment

Файл workflow:

```text
.github/workflows/deploy.yml
```

---

# Перевірка розгортання

Verification script перевіряє:

- GET /
- GET /notes
- GET /health/alive безпосередньо у контейнері
- прихований health endpoint через nginx

Файл verification:

```text
mywebapp/deploy/verify.sh
```

---

# Self-hosted Runner

Labels runner:

```text
self-hosted
Linux
ARM64
```

---

# Результат

Застосунок було успішно:

- протестовано
- контейнеризовано
- опубліковано у GitHub Container Registry
- автоматично розгорнуто на віддаленій віртуальній машині
- перевірено після deployment
