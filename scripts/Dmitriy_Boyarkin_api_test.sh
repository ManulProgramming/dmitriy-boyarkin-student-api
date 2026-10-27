#!/usr/bin/env bash
# Task 3.4 - curl API tests for Dmitriy Boyarkin's Student API
# Usage: ./scripts/Dmitriy_Boyarkin_api_test.sh [BASE_URL]      (default http://localhost:8081)
BASE="${1:-http://localhost:8081}"
LOG="$(dirname "$0")/../logs/Dmitriy_Boyarkin_api_test.log"
mkdir -p "$(dirname "$LOG")"
{
echo "== API test for Dmitriy Boyarkin - $(date) - $BASE =="
echo; echo "### 0. Info (shows student name)"
curl -s -w "\nHTTP %{http_code}\n" "$BASE/api/info"

echo; echo "### 1. Create student (POST)"
RESP=$(curl -s -w "\nHTTP %{http_code}" -X POST "$BASE/api/students" \
  -H 'Content-Type: application/json' \
  -d '{"firstName":"Dmitriy","lastName":"Boyarkin","email":"dmitriy.boyarkin.curl@example.com","studentCode":"DB-CURL-01"}')
echo "$RESP"
ID=$(echo "$RESP" | sed -n 's/.*"id":\([0-9]*\).*/\1/p' | head -1)
echo "Created id = $ID"

echo; echo "### 2. Get all students"
curl -s -w "\nHTTP %{http_code}\n" "$BASE/api/students"

echo; echo "### 3. Get student by id $ID"
curl -s -w "\nHTTP %{http_code}\n" "$BASE/api/students/$ID"

echo; echo "### 4. Update student $ID (PUT)"
curl -s -w "\nHTTP %{http_code}\n" -X PUT "$BASE/api/students/$ID" \
  -H 'Content-Type: application/json' \
  -d '{"firstName":"Dmitriy","lastName":"Boyarkin-Updated","email":"dmitriy.boyarkin.curl@example.com","studentCode":"DB-CURL-01"}'

echo; echo "### 5. Delete student $ID"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X DELETE "$BASE/api/students/$ID"

echo; echo "### 6. Get deleted / nonexistent student (expect 404)"
curl -s -w "\nHTTP %{http_code}\n" "$BASE/api/students/$ID"

echo; echo "### 7. Search by surname (feature/dmitriy-boyarkin-crud)"
curl -s -w "\nHTTP %{http_code}\n" "$BASE/api/students/search?lastName=boyarkin"
} 2>&1 | tee -a "$LOG"
