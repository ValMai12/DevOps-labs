# Лабораторна робота №2
# Контейнеризація

---

# Інформація про студента

ПІБ: 
Маєвська Валерія Олександрівна ІМ-41

Репозиторій:
https://github.com/ValMai12/DevOps-labs/tree/lab2

---

# Мета роботи

Метою лабораторної роботи було дослідження підходів до контейнеризації застосунків та практичне використання Docker і Docker Compose для упаковки та запуску системи сервісів.

У межах роботи були виконані:
- експерименти з контейнеризацією Python-застосунку
- оптимізація Docker layers
- порівняння Debian та Alpine образів
- дослідження поведінки musl та glibc
- експерименти з multi-stage builds для Go
- контейнеризація застосунку з Лабораторної роботи №1

---

# Середовище виконання

Експерименти виконувалися на:

- macOS
- Apple Silicon MacBook Pro M3
- Docker Desktop

---

# Частина 1 — Експерименти з Python-застосунком

Репозиторій:
https://github.com/KPI-FICT-MTSD/lab-03-starter-project-python

---

# Експеримент 1 — Неоптимальний Dockerfile

Dockerfile:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements/backend.in

EXPOSE 8000

CMD ["python", "-m", "spaceship.main"]
```

### Команди для відтворення

```bash
time docker build -f Dockerfile.bad -t spaceship-python:bad .
docker images spaceship-python:bad
```

## Результати

Перша збірка:

- Час збірки: ~12 секунд
- Disk usage: 270MB
- Content size: 58.7MB

Після зміни лише файлу build/index.html:

- Час збірки: ~12 секунд повторно

## Аналіз

Dockerfile копіював увесь проєкт перед встановленням залежностей.

Через це:
- будь-яка зміна коду інвалідовувала Docker cache
- pip install запускався повторно під час кожної збірки

Такий підхід неефективно використовує Docker layers.

---

# Експеримент 2 — Оптимізований Dockerfile

Dockerfile:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements/backend.in requirements/backend.in

RUN pip install --no-cache-dir -r requirements/backend.in

COPY . .

EXPOSE 8000

CMD ["python", "-m", "spaceship.main"]
```
### Команди для відтворення

```bash
time docker build -f Dockerfile.good -t spaceship-python:good .
docker images spaceship-python:good
```

## Результати

Перша збірка:

- Час збірки: ~20 секунд
- Disk usage: 270MB
- Content size: 58.7MB

Після зміни лише файлу build/index.html:

- Час збірки: ~1.5 секунди

## Аналіз

Залежності встановлювалися окремим layer, тому Docker зміг використати cache.

Після зміни лише HTML-файлів:
- pip install не запускався повторно
- Docker повторно використав cached layers

Оптимізований Dockerfile значно пришвидшив повторну збірку образу.

---

# Експеримент 3 — Alpine Base Image

Dockerfile:

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY requirements/backend.in requirements/backend.in

RUN pip install --no-cache-dir -r requirements/backend.in

COPY . .

EXPOSE 8000

CMD ["python", "-m", "spaceship.main"]
```

### Команди для відтворення

```bash
time docker build -f Dockerfile.alpine -t spaceship-python:alpine .
docker images spaceship-python:alpine
```

## Результати

- Час збірки: ~24 секунди
- Disk usage: 143MB
- Content size: 34MB

## Аналіз

Alpine-based image виявився значно меншим за Debian-based image.

Проте:
- час збірки був дещо довшим
- сумісність може бути нижчою через використання musl libc замість glibc

---

# Експеримент 4 — Додавання numpy

У проєкт був доданий endpoint:

```text
/matrix
```

Endpoint:
- генерує дві випадкові матриці 10x10
- перемножує їх за допомогою numpy
- повертає результат у JSON

## Debian-based image з numpy

Результати:

- Час збірки: ~21 секунда
- Disk usage: 361MB
- Content size: 78.5MB

## Alpine-based image з numpy

Результати:

- Час збірки: ~23.5 секунди
- Disk usage: 238MB
- Content size: 55.2MB

## Аналіз

Навіть після додавання numpy Alpine image залишився значно меншим.

Проте:
- Alpine build був повільнішим
- scientific Python packages можуть вимагати додаткової компіляції в Alpine

Debian-based image забезпечує:
- кращу сумісність
- простішу роботу із залежностями

## Dependency pinning

Для максимально відтворюваних build рекомендується використовувати pinned dependencies.

У Python-проєктах це можна реалізувати через:
- pip freeze
- requirements.txt із фіксованими версіями
- poetry.lock
- pip-tools

У межах лабораторної роботи використовувався requirements/backend.in, проте для production deployment доцільно фіксувати точні версії всіх залежностей.

---

# Частина 2 — musl vs glibc DNS Behavior

Було створено окрему Docker network:

```bash
docker network create dns-lab
```

Також був запущений dnsmasq DNS server із кастомним доменом:

```text
myservice.internal.corp
```

IP-адреса:

```text
10.0.0.50
```

---

# Ubuntu / glibc тест

Команда:

```bash
docker run --rm --network dns-lab \
  --dns=<dns-server-ip> \
  --dns-search="corp" \
  ubuntu:latest getent hosts myservice.internal
```

Результат:

```text
10.0.0.50 myservice.internal.corp
```

---

# Alpine / musl тест

Команда:

```bash
docker run --rm --network dns-lab \
  --dns=<dns-server-ip> \
  --dns-search="corp" \
  alpine:latest getent hosts myservice.internal
```

Результат:

```text
результат відсутній
```

---

# DNS Logs

```text
query[A] myservice.internal
reply myservice.internal is NXDOMAIN

query[A] myservice.internal.corp
config myservice.internal.corp is 10.0.0.50
```

---

# Аналіз

Ubuntu/glibc коректно застосував DNS search domain та перетворив:

```text
myservice.internal
```

на:

```text
myservice.internal.corp
```

Після цього домен був успішно зарезолвлений.

Alpine/musl поводився інакше та не повернув той самий результат.

Така різниця може призводити до проблем service discovery у контейнеризованих середовищах, якщо застосунок покладається на DNS search domains.

---

# Частина 3 — Golang Multi-stage Builds

Репозиторій:
https://github.com/comsys-kpi-ua/deploy.lab-containers-starter-project-golang

---

# Експеримент 1 — Базовий Docker image

Dockerfile:

```dockerfile
FROM golang:1.24

WORKDIR /app

COPY . .

RUN go build -o app .

EXPOSE 8080

CMD ["./app", "serve"]
```

### Команди для відтворення

```bash
time docker build -f Dockerfile.basic -t go-fizzbuzz:basic .
docker images go-fizzbuzz:basic
```

## Результати

- Час збірки: ~4 хвилини 46 секунд
- Disk usage: 1.47GB
- Content size: 345MB

## Аналіз

Образ вийшов дуже великим, оскільки містив:
- Go compiler
- build cache
- source code
- залежності
- додаткові build tools

Такий підхід не є ефективним для production deployment.

---

# Експеримент 2 — Multi-stage build із scratch

Dockerfile:

```dockerfile
FROM golang:1.24 AS builder

WORKDIR /app

COPY . .

RUN go build -o app .


FROM scratch

WORKDIR /app

COPY --from=builder /app/app /app/app
COPY --from=builder /app/templates /app/templates

EXPOSE 8080

CMD ["/app/app", "serve"]
```

### Команди для відтворення

```bash
time docker build -f Dockerfile.multistage -t go-fizzbuzz:multistage .
docker images go-fizzbuzz:multistage
```

## Результати

- Час збірки: ~7 секунд
- Disk usage: 18.5MB
- Content size: 6.46MB

## Аналіз

Фінальний image містив лише:
- скомпільований binary file
- templates

В image не було:
- compiler
- source code
- build dependencies

Це дозволило дуже сильно зменшити розмір image.

Проте scratch image має і недоліки:
- відсутній shell
- відсутні системні утиліти
- складніше виконувати debugging контейнера
- складніше аналізувати runtime проблеми

Такі image добре підходять для production deployment, але менш зручні для діагностики.

---

# Експеримент 3 — Distroless image

Dockerfile:

```dockerfile
FROM golang:1.24 AS builder

WORKDIR /app

COPY . .

RUN go build -o app .


FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=builder /app/app /app/app
COPY --from=builder /app/templates /app/templates

EXPOSE 8080

CMD ["/app/app", "serve"]
```

### Команди для відтворення

```bash
time docker build -f Dockerfile.distroless -t go-fizzbuzz:distroless .
docker images go-fizzbuzz:distroless
```

## Результати

- Час збірки: ~9 секунд
- Disk usage: 24.6MB
- Content size: 7.17MB

## Аналіз

Distroless image був трохи більшим за scratch image, але залишився дуже компактним.

Переваги distroless image:
- мінімальний runtime environment
- менша attack surface
- краща безпека
- distroless image є практичнішим для production runtime у порівнянні зі scratch

---

# Частина 4 — Контейнеризація застосунку з Лабораторної роботи №1

Для контейнеризації застосунку з Лабораторної роботи №1 був використаний Docker Compose.

Було контейнеризовано:
- Flask web application
- MariaDB database
- nginx reverse proxy

---

# Docker Compose

Було створено:
- окрему Docker network
- persistent volume для MariaDB
- автоматичний запуск усіх сервісів
- reverse proxy через nginx

Сервіси запускалися командою:

```bash
docker compose up --build
```

Фоновий запуск:

```bash
docker compose up -d
```

Зупинка:

```bash
docker compose down
```

---

# Перевірка persistence

Persistence було перевірено шляхом:
1. створення note через API
2. перезапуску контейнерів
3. повторної перевірки даних

Дані збереглися після:
- restart контейнерів
- docker compose down
- docker compose up

Це підтвердило коректну роботу persistent volume.

---

# Висновки

У ході лабораторної роботи було досліджено різні підходи до контейнеризації застосунків.

Основні висновки:

- правильний порядок Docker layers значно впливає на швидкість rebuild
- optimized Dockerfile дозволяє ефективно використовувати Docker cache
- Alpine images є значно меншими, але можуть створювати проблеми із сумісністю
- Debian-based images забезпечують кращу сумісність
- multi-stage builds дозволяють радикально зменшити розмір Go images
- distroless images є хорошим компромісом між мінімалізмом та практичним використанням
- Docker Compose значно спрощує orchestration multi-container systems

Контейнеризація дозволяє:
- стандартизувати середовище виконання
- спростити deployment
- забезпечити reproducible builds
- ізолювати сервіси один від одного
- спростити масштабування та підтримку системи