# Dmitriy Boyarkin - Student API

Spring Boot 3 / Java 17 CRUD REST API for students, backed by PostgreSQL, containerised with Docker Compose and built by a Jenkins pipeline.

Author: **Dmitriy Boyarkin**
Status: Initial version (Dmitriy Boyarkin)

## Project structure
```
dmitriy-boyarkin-student-api/
├── scripts/            Bash scripts (system report, API tests, Docker demo, helpers)
├── logs/               Personal logs (system report, log analysis, API test)
├── backups/            README backup
├── src/                Spring Boot sources and tests
├── docs/               Written answers, Jenkins runbook
├── Dockerfile          Multi-stage build (gradle:8.10.2-jdk17 -> eclipse-temurin:17-jre-alpine)
├── docker-compose.yml  App + PostgreSQL, named volume, own network, health check
├── Jenkinsfile         Checkout -> Build -> Test -> Docker Build -> Verify
└── build.gradle
```

## REST API
| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/info` | Student name and application version |
| GET | `/api/students` | List all students |
| GET | `/api/students/{id}` | One student (404 JSON if missing) |
| POST | `/api/students` | Create (201, validated) |
| PUT | `/api/students/{id}` | Update |
| DELETE | `/api/students/{id}` | Delete (204) |

Individual seed data: Dmitriy Boyarkin (`DB-2026-001`) and Aigerim Testova (`DB-2026-002`).

## Run with Docker Compose
```bash
cp .env.example .env          # then edit POSTGRES_PASSWORD (never commit .env)
docker compose up -d --build
curl http://localhost:8081/api/info
./scripts/Dmitriy_Boyarkin_api_test.sh
```
Image: `dmitriy-boyarkin-student-api:v1.0-dmitriy-boyarkin` - Compose project: `dmitriy-boyarkin-student-api` - volume: `dmitriy_boyarkin_pgdata` - network: `dmitriy_boyarkin_net`.
The application reaches the database at `jdbc:postgresql://db:5432/...` (Compose service name, not `localhost`).

## Run tests locally
```bash
gradle test        # or ./gradlew test after generating the wrapper (see docs/JENKINS_SETUP.md)
```
Tests use an in-memory H2 database (profile `test`), so no PostgreSQL is needed.

## Change log
* v1.0-dmitriy-boyarkin - initial CRUD API, Docker, Jenkins pipeline.
