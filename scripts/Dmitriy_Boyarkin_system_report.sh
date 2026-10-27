#!/usr/bin/env bash
# =============================================================================
# Dmitriy_Boyarkin_system_report.sh  -  Personal system monitoring script
# Student : Dmitriy Boyarkin
# Output  : printed to the terminal AND appended to logs/Dmitriy_Boyarkin_system_report.log
# =============================================================================
set -u

STUDENT_NAME="Dmitriy Boyarkin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../logs/Dmitriy_Boyarkin_system_report.log"
mkdir -p "$(dirname "$LOG_FILE")"

section() { printf '\n--- %s ---\n' "$1"; }

report() {
  echo "=============================================================="
  echo " SYSTEM REPORT"
  echo "=============================================================="
  echo "Student full name : ${STUDENT_NAME}"
  echo "Date and time     : $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "Current username  : $(whoami)"
  echo "Hostname          : $(hostname)"

  section "Operating system and kernel"
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "OS     : ${PRETTY_NAME:-unknown}"
  else
    echo "OS     : $(uname -s)"
  fi
  echo "Kernel : $(uname -r)"
  echo "Arch   : $(uname -m)"

  section "CPU information"
  if command -v lscpu >/dev/null 2>&1; then
    lscpu | grep -E '^(Architecture|Model name|CPU\(s\)|Thread|Core)' || true
  else
    grep -m1 'model name' /proc/cpuinfo || true
    echo "CPU cores: $(nproc)"
  fi

  section "Memory information"
  free -h

  section "Disk usage"
  df -h

  section "Available disk space (root filesystem)"
  df -h --output=source,size,used,avail,pcent,target / 2>/dev/null || df -h /

  echo
  echo "Report finished for ${STUDENT_NAME}"
  echo "=============================================================="
}

report | tee -a "$LOG_FILE"
echo "[saved to: ${LOG_FILE}]"
