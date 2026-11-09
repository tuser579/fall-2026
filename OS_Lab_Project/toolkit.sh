#!/bin/bash
# =====================================================================
#  SYSADMIN TOOLKIT  -  Shell Script Based Project
#  Automates: disk monitoring, backups, process management,
#             system health, user management, basic network checks
#
#  Run it:        ./toolkit.sh
#  Auto mode:     ./toolkit.sh --auto     (no menu, good for cron)
# =====================================================================

# ---------- 1. SETTINGS (change these if you want) -------------------
BASE_DIR="$HOME/sysadmin_toolkit"
LOG_FILE="$BASE_DIR/toolkit.log"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
DISK_LIMIT=80        # warn when a disk is this % full or more
MEM_LIMIT=80         # warn when memory use is this % or more
KEEP_DAYS=7          # old backups older than this can be cleaned

mkdir -p "$BACKUP_DIR" "$REPORT_DIR"

# ---------- 2. COLORS AND HELPER FUNCTIONS ---------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; }
title(){ echo -e "\n${BLUE}===== $1 =====${NC}"; }

# Write a line to the log file with date and time
log() { echo "$(date '+%F %T') - $1" >> "$LOG_FILE"; }

pause() { echo; read -rp "Press Enter to continue..." _; }

# Ask a yes/no question. Returns success only if user types y or Y.
confirm() { read -rp "$1 (y/n): " a; [[ "$a" == "y" || "$a" == "Y" ]]; }

# ---------- 3. DISK MONITORING ---------------------------------------
disk_monitor() {
  title "DISK USAGE"
  df -h -x tmpfs -x devtmpfs -x squashfs
  echo
  # Check every disk and compare with the limit
  df -P -x tmpfs -x devtmpfs -x squashfs | awk 'NR>1 {print $6, $5}' |
  while read -r mount pct; do
    num=${pct%\%}                      # remove the % sign
    if [ "$num" -ge "$DISK_LIMIT" ]; then
      warn "$mount is ${num}% full (limit ${DISK_LIMIT}%)"
      log "DISK WARNING: $mount ${num}%"
    else
      ok "$mount is ${num}% full"
    fi
  done
  echo
  echo "Top 5 biggest folders in your home directory:"
  du -h --max-depth=1 "$HOME" 2>/dev/null | sort -rh | head -6
  log "Disk check run"
}

# ---------- 4. BACKUP AUTOMATION -------------------------------------
backup_create() {
  read -rp "Folder to back up (example: ~/Documents): " src
  src="${src/#\~/$HOME}"               # turn ~ into /home/user
  if [ ! -d "$src" ]; then err "Folder not found: $src"; return; fi

  file="$BACKUP_DIR/backup_$(basename "$src")_$(date +%F_%H%M%S).tar.gz"
  if tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")" 2>/dev/null; then
    ok "Backup created: $file ($(du -h "$file" | cut -f1))"
    log "Backup created: $file"
  else
    err "Backup failed"; log "Backup FAILED for $src"
  fi
}

backup_list() {
  title "EXISTING BACKUPS"
  ls -lh "$BACKUP_DIR" | tail -n +2
  [ -z "$(ls -A "$BACKUP_DIR")" ] && echo "No backups yet."
}

backup_restore() {
  files=("$BACKUP_DIR"/*.tar.gz)
  if [ ! -e "${files[0]}" ]; then err "No backups to restore"; return; fi
  echo "Choose a backup to restore:"
  select f in "${files[@]}"; do
    [ -n "$f" ] || { err "Invalid choice"; return; }
    dest="$BASE_DIR/restored"
    mkdir -p "$dest"
    tar -xzf "$f" -C "$dest" && ok "Restored into $dest"
    log "Restored $f"
    break
  done
}

backup_cleanup() {
  old=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS")
  if [ -z "$old" ]; then ok "No backups older than $KEEP_DAYS days"; return; fi
  echo "$old"
  if confirm "Delete these old backups?"; then
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete
    ok "Old backups deleted"; log "Old backups cleaned"
  fi
}

backup_menu() {
  title "BACKUP MENU"
  echo "1) Create backup   2) List backups   3) Restore backup   4) Delete old backups"
  read -rp "Choose: " c
  case $c in
    1) backup_create ;;
    2) backup_list ;;
    3) backup_restore ;;
    4) backup_cleanup ;;
    *) err "Invalid option" ;;
  esac
}

# ---------- 5. PROCESS MANAGEMENT ------------------------------------
process_menu() {
  title "PROCESS MANAGEMENT"
  echo "1) Top 5 CPU processes   2) Top 5 memory processes"
  echo "3) Search a process      4) Kill a process"
  read -rp "Choose: " c
  case $c in
    1) ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6 ;;
    2) ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6 ;;
    3) read -rp "Process name: " n
       pgrep -a "$n" || warn "No process found named '$n'" ;;
    4) read -rp "PID to kill: " pid
       if ! [[ "$pid" =~ ^[0-9]+$ ]]; then err "PID must be a number"; return; fi
       if ! ps -p "$pid" > /dev/null; then err "No such PID"; return; fi
       if confirm "Really kill process $pid ($(ps -p "$pid" -o comm=))?"; then
         if kill "$pid" 2>/dev/null; then
           ok "Process $pid stopped"; log "Killed PID $pid"
         else
           err "Could not kill it (it may belong to another user)"
         fi
       fi ;;
    *) err "Invalid option" ;;
  esac
}

# ---------- 6. SYSTEM HEALTH MONITORING ------------------------------
health_check() {
  title "SYSTEM HEALTH"
  echo "Hostname : $(hostname)"
  echo "Uptime   : $(uptime -p)"
  echo "Kernel   : $(uname -r)"

  cores=$(nproc)
  load=$(cut -d' ' -f1 /proc/loadavg)
  echo "CPU load : $load (cores: $cores)"
  # Load higher than number of cores means CPU is overloaded
  if awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'; then
    warn "CPU is overloaded"; log "HEALTH WARNING: high CPU load $load"
  else
    ok "CPU load is normal"
  fi

  mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
  echo "Memory   : ${mem}% used"
  if [ "$mem" -ge "$MEM_LIMIT" ]; then
    warn "Memory usage is high"; log "HEALTH WARNING: memory ${mem}%"
  else
    ok "Memory usage is normal"
  fi

  root=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
  echo "Disk (/) : ${root}% used"
  if [ "$root" -ge "$DISK_LIMIT" ]; then
    warn "Root disk is nearly full"; log "HEALTH WARNING: root disk ${root}%"
  else
    ok "Disk usage is normal"
  fi
  log "Health check run"
}

save_report() {
  file="$REPORT_DIR/report_$(date +%F_%H%M%S).txt"
  {
    echo "SYSTEM REPORT - $(date)"
    echo "----------------------------------"
    uptime
    echo; free -h
    echo; df -h -x tmpfs -x devtmpfs -x squashfs
    echo; echo "Top 5 CPU processes:"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
    echo; echo "Logged-in users:"; who
  } > "$file"
  ok "Report saved: $file"; log "Report saved: $file"
}

# ---------- 7. USER MANAGEMENT ---------------------------------------
user_menu() {
  title "USER MANAGEMENT"
  echo "1) List users   2) Add user   3) Delete user"
  echo "4) Lock user    5) Unlock user"
  read -rp "Choose: " c
  case $c in
    1) echo "Normal users on this system:"
       awk -F: '$3>=1000 && $3<65534 {print " - "$1}' /etc/passwd ;;
    2) read -rp "New username: " u
       if ! [[ "$u" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then err "Invalid username"; return; fi
       if id "$u" &>/dev/null; then err "User already exists"; return; fi
       sudo useradd -m -s /bin/bash "$u" && sudo passwd "$u" &&
         { ok "User $u created"; log "User added: $u"; } ;;
    3) read -rp "Username to delete: " u
       if [ "$u" == "$USER" ]; then err "You cannot delete yourself"; return; fi
       if ! id "$u" &>/dev/null; then err "No such user"; return; fi
       if confirm "Delete $u and their home folder?"; then
         sudo userdel -r "$u" && { ok "User $u deleted"; log "User deleted: $u"; }
       fi ;;
    4) read -rp "Username to lock: " u
       sudo usermod -L "$u" && { ok "$u locked"; log "User locked: $u"; } ;;
    5) read -rp "Username to unlock: " u
       sudo usermod -U "$u" && { ok "$u unlocked"; log "User unlocked: $u"; } ;;
    *) err "Invalid option" ;;
  esac
}

# ---------- 8. BASIC NETWORK MANAGEMENT ------------------------------
network_menu() {
  title "NETWORK TOOLS"
  echo "1) Show IP addresses   2) Test internet (ping)   3) Show open ports"
  read -rp "Choose: " c
  case $c in
    1) ip -brief addr ;;
    2) if ping -c 3 -W 2 8.8.8.8 > /dev/null 2>&1; then
         ok "Internet is reachable"
       else
         err "No internet connection"; log "NETWORK: ping failed"
       fi ;;
    3) ss -tuln ;;
    *) err "Invalid option" ;;
  esac
  log "Network tool used"
}

# ---------- 9. VIEW LOG FILE -----------------------------------------
view_log() {
  title "LAST 20 LOG ENTRIES"
  if [ -f "$LOG_FILE" ]; then tail -20 "$LOG_FILE"; else echo "Log is empty."; fi
}

# ---------- 10. AUTO MODE (for cron) ---------------------------------
if [ "$1" == "--auto" ]; then
  disk_monitor > /dev/null
  health_check > /dev/null
  save_report  > /dev/null
  log "Auto mode finished"
  exit 0
fi

# ---------- 11. MAIN MENU --------------------------------------------
while true; do
  clear
  echo -e "${BLUE}==============================================${NC}"
  echo -e "${BLUE}        SYSADMIN TOOLKIT  -  Main Menu${NC}"
  echo -e "${BLUE}==============================================${NC}"
  echo " 1) Disk monitoring"
  echo " 2) Backup automation"
  echo " 3) Process management"
  echo " 4) System health check"
  echo " 5) Save system report"
  echo " 6) User management"
  echo " 7) Network tools"
  echo " 8) View log file"
  echo " 9) Exit"
  read -rp "Choose an option [1-9]: " choice

  case $choice in
    1) disk_monitor ;;
    2) backup_menu ;;
    3) process_menu ;;
    4) health_check ;;
    5) save_report ;;
    6) user_menu ;;
    7) network_menu ;;
    8) view_log ;;
    9) log "Toolkit closed"; echo "Goodbye!"; exit 0 ;;
    *) err "Invalid option, choose 1-9" ;;
  esac
  pause
done
