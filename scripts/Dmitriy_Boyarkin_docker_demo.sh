#!/usr/bin/env bash
# Tasks 3.1 - 3.3 - Docker demonstration for Dmitriy Boyarkin. Run from the project root.
# Requires: Docker + Docker Compose v2, and a .env file (cp .env.example .env).
set -e
LOG=logs/Dmitriy_Boyarkin_docker_demo.log
mkdir -p logs
exec > >(tee -a "$LOG") 2>&1
step() { echo; echo "######## $* ########"; }

step "3.1 Build image dmitriy-boyarkin-student-api:v1.0-dmitriy-boyarkin"
docker build --build-arg APP_VERSION=v1.0-dmitriy-boyarkin -t dmitriy-boyarkin-student-api:v1.0-dmitriy-boyarkin .
docker images dmitriy-boyarkin-student-api
docker image inspect dmitriy-boyarkin-student-api:v1.0-dmitriy-boyarkin --format 'Created: {{.Created}}  Size: {{.Size}} bytes  Arch: {{.Architecture}}'

step "3.2 Start Compose project dmitriy-boyarkin-student-api"
docker compose up -d --build
sleep 20
docker compose ps
echo "--- application connects to host 'db' (service name), not localhost:"
docker compose exec -T app env | grep SPRING_DATASOURCE_URL

step "3.3.1 Running containers"
docker ps --filter "name=dmitriy-boyarkin"

step "3.3.2 Application logs"
docker logs --tail 30 dmitriy-boyarkin-student-app

step "3.3.3 Inspect container configuration (image, env names, network, mounts)"
docker inspect dmitriy-boyarkin-student-app --format 'Image={{.Config.Image}} Networks={{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'
docker inspect dmitriy-boyarkin-postgres  --format 'Mounts: {{range .Mounts}}{{.Name}} -> {{.Destination}} {{end}}'

step "3.3.4 Execute command inside application container"
docker exec dmitriy-boyarkin-student-app sh -c 'whoami && java -version 2>&1 | head -1 && ls -l /app'

step "3.3.5 Stop and restart the application service"
docker compose stop app
docker compose ps -a
docker compose start app
sleep 15
docker compose ps

step "3.3.7 (part 1) Create a record before restart"
curl -s -X POST http://localhost:${APP_PORT:-8081}/api/students -H 'Content-Type: application/json' \
  -d '{"firstName":"Dmitriy","lastName":"Boyarkin","email":"persist.boyarkin@example.com","studentCode":"DB-PERSIST"}'; echo

step "3.3.7 (part 2) docker compose down (WITHOUT -v) and up again"
docker compose down
docker compose up -d
sleep 25
curl -s http://localhost:${APP_PORT:-8081}/api/students; echo
echo "^ the persist.boyarkin@example.com record must still be listed (named volume dmitriy_boyarkin_pgdata)"
docker volume ls --filter name=dmitriy_boyarkin_pgdata

step "3.3.6 Rebuild image after changing the application version to v1.1-dmitriy-boyarkin"
APP_VERSION=v1.1-dmitriy-boyarkin docker compose up -d --build app
sleep 15
curl -s http://localhost:${APP_PORT:-8081}/api/info; echo
docker images dmitriy-boyarkin-student-api
