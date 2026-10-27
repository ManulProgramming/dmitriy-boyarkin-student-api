#!/usr/bin/env bash
# Task 2.4 - push to YOUR GitHub repository dmitriy-boyarkin-student-api.
# 1) Create an EMPTY repo named dmitriy-boyarkin-student-api on github.com (no README/licence).
# 2) Run: ./scripts/Dmitriy_Boyarkin_push_to_github.sh <your-github-username>
set -e
USER_GH="${1:?usage: $0 <github-username>}"
URL="https://github.com/${USER_GH}/dmitriy-boyarkin-student-api.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$URL"
git push -u origin main
git push origin --all
git push origin v1.0-dmitriy-boyarkin
echo "--- remote / branches / tag ---"
git remote -v
git branch -a
git tag -l
git log --oneline --graph --decorate --all
