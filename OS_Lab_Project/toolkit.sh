#!/bin/bash
# SysAdmin Toolkit — Menu-driven Linux automation script
# Run normally:  ./toolkit.sh
# Run silently:  ./toolkit.sh --auto

# --- 1. Settings ---
BASE_DIR="$HOME/sysadmin_toolkit"
LOG_FILE="$BASE_DIR/toolkit.log"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
DISK_LIMIT=80
MEM_LIMIT=80
KEEP_DAYS=7

mkdir -p "$BACKUP_DIR" "$REPORT_DIR"

# --- 2. Colors and Helper Functions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()      { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }
err()     { echo -e "${RED}[ERROR]${NC} $1"; }
title()   { echo -e "\n${BLUE}===== $1 =====${NC}"; }
log()     { echo "$(date '+%F %T') - $1" >> "$LOG_FILE"; }
pause()   { echo; read -rp "Press Enter to continue..." _; }
confirm() { read -rp "$1 (y/n): " a; [[ "$a" == "y" || "$a" == "Y" ]]; }

# --- 3. Disk Monitoring ---
disk_monitor() {
  title "DISK USAGE"
  df -h -x tmpfs -x devtmpfs -x squashfs
  echo

  # Check each drive's used % against DISK_LIMIT
  df -P -x tmpfs -x devtmpfs -x squashfs | awk 'NR>1 {print $6, $5}' |
  while read -r mount pct; do
    num=${pct%\%}
    if [ "$num" -ge "$DISK_LIMIT" ]; then
      warn "$mount is ${num}% full (limit ${DISK_LIMIT}%)"
      log "DISK WARNING: $mount ${num}%"
    else
      ok "$mount is ${num}% full"
    fi
  done

  echo
  echo "Top 5 biggest folders in your home directory:"
  echo "(Scanning folders, please wait...)"
  du -h --max-depth=1 --exclude="AppData" "$HOME" 2>/dev/null | sort -rh | head -6
  log "Disk check run"
}

# --- 4. Backup Automation ---
backup_create() {
  read -rp "Folder to back up (example: ~/Documents): " src
  src="${src/#\~/$HOME}"
  if [ ! -d "$src" ]; then
    err "Folder not found: $src"
    return
  fi

  file="$BACKUP_DIR/backup_$(basename "$src")_$(date +%F_%H%M%S).tar.gz"
  if tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")" 2>/dev/null; then
    ok "Backup created: $file ($(du -h "$file" | cut -f1))"
    log "Backup created: $file"
  else
    err "Backup failed"
    log "Backup FAILED for $src"
  fi
}

backup_list() {
  title "EXISTING BACKUPS"
  ls -lh "$BACKUP_DIR" | tail -n +2
  [ -z "$(ls -A "$BACKUP_DIR")" ] && echo "No backups yet."
}

backup_restore() {
  files=("$BACKUP_DIR"/*.tar.gz)
  if [ ! -e "${files[0]}" ]; then
    err "No backups to restore"
    return
  fi

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
  if [ -z "$old" ]; then
    ok "No backups older than $KEEP_DAYS days"
    return
  fi

  echo "$old"
  if confirm "Delete these old backups?"; then
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete
    ok "Old backups deleted"
    log "Old backups cleaned"
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

# --- 5. Process Management ---
top_cpu_procs() {
  if ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu >/dev/null 2>&1; then
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
  else
    ps -W 2>/dev/null | head -6 || ps -e | head -6
  fi
}

top_mem_procs() {
  if ps -eo pid,user,%cpu,%mem,comm --sort=-%mem >/dev/null 2>&1; then
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6
  elif command -v tasklist >/dev/null 2>&1; then
    echo "PID      MEM (MB)    COMMAND"
    MSYS_NO_PATHCONV=1 tasklist /FO CSV /NH | tr -d '\r' |
      awk -F'","' '{gsub(/^"|"$/,""); mem=$5; gsub(/[^0-9]/,"",mem); printf "%-8s %8.1f    %s\n", $2, mem/1024, $1}' |
      sort -k2 -rn | head -5
  else
    ps -e | head -6
  fi
}

process_menu() {
  title "PROCESS MANAGEMENT"
  echo "1) Top 5 CPU processes   2) Top 5 memory processes"
  echo "3) Search a process      4) Kill a process"
  read -rp "Choose: " c
  case $c in
    1) top_cpu_procs ;;
    2) top_mem_procs ;;
    3) read -rp "Process name: " n
       if command -v pgrep >/dev/null 2>&1; then
         pgrep -a "$n" || warn "No process found named '$n'"
       else
         ps -W 2>/dev/null | grep -i "$n" || warn "No process found named '$n'"
       fi ;;
    4) read -rp "PID to kill: " pid
       if ! [[ "$pid" =~ ^[0-9]+$ ]]; then err "PID must be a number"; return; fi
       pname=""
       if ps -p "$pid" -o comm= >/dev/null 2>&1; then
         pname=$(ps -p "$pid" -o comm=)
       elif ps -p "$pid" >/dev/null 2>&1; then
         pname=$(ps -p "$pid" | awk 'NR==2 {print $NF}')
       elif command -v tasklist >/dev/null 2>&1; then
         pname=$(MSYS_NO_PATHCONV=1 tasklist /FI "PID eq $pid" /FO CSV /NH 2>/dev/null | tr -d '\r' | awk -F'","' '/^"/ {gsub(/^"/,"",$1); print $1; exit}')
       fi
       if [ -z "$pname" ]; then err "No such PID"; return; fi
       if confirm "Really kill process $pid ($pname)?"; then
         if kill "$pid" 2>/dev/null || (command -v taskkill >/dev/null 2>&1 && MSYS_NO_PATHCONV=1 taskkill /PID "$pid" >/dev/null 2>&1); then
           ok "Process $pid stopped"
           log "Killed PID $pid"
         else
           err "Could not kill it (it may belong to another user)"
         fi
       fi ;;
    *) err "Invalid option" ;;
  esac
}

# --- 6. System Health Check & Report ---
get_uptime() {
  if command -v uptime >/dev/null 2>&1; then
    uptime -p
  elif [ -r /proc/uptime ]; then
    awk '{s=int($1); printf "up %d days, %d hours, %d minutes\n", int(s/86400), int((s%86400)/3600), int((s%3600)/60)}' /proc/uptime
  else
    echo "unavailable"
  fi
}

get_mem_pct() {
  if command -v free >/dev/null 2>&1; then
    free | awk '/Mem:/ {printf "%.0f", $3/$2*100}'
  elif [ -r /proc/meminfo ]; then
    awk '/^MemTotal:/ {t=$2} /^MemFree:/ {f=$2} END {if (t>0) printf "%.0f", (t-f)/t*100; else print 0}' /proc/meminfo
  else
    echo 0
  fi
}

check_battery() {
  bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
  if [ -n "$bat" ]; then
    cap=$(cat "$bat/capacity" 2>/dev/null)
    status=$(cat "$bat/status" 2>/dev/null)
    full=""; design=""; health_pct=""
    if [ -f "$bat/energy_full" ] && [ -f "$bat/energy_full_design" ]; then
      full=$(cat "$bat/energy_full"); design=$(cat "$bat/energy_full_design")
    elif [ -f "$bat/charge_full" ] && [ -f "$bat/charge_full_design" ]; then
      full=$(cat "$bat/charge_full"); design=$(cat "$bat/charge_full_design")
    fi
    if [ -n "$full" ] && [ -n "$design" ] && [ "$design" -gt 0 ] 2>/dev/null; then
      health_pct=$(( full * 100 / design ))
      [ "$health_pct" -gt 100 ] && health_pct=100
    fi

    echo "Battery  : ${cap:-?}% (${status:-Unknown})${health_pct:+, Health: ${health_pct}%}"
    if [ -n "$health_pct" ] && [ "$health_pct" -lt 80 ]; then
      warn "Battery health is low (${health_pct}%)"
      log "HEALTH WARNING: battery health ${health_pct}%"
    elif [ "${cap:-100}" -le 20 ] && [ "$status" == "Discharging" ]; then
      warn "Battery charge is low (${cap}%)"
      log "HEALTH WARNING: low battery ${cap}%"
    else
      ok "Battery health is normal"
    fi
  elif command -v wmic >/dev/null 2>&1; then
    info=$(wmic path Win32_Battery get BatteryStatus,EstimatedChargeRemaining /format:csv 2>/dev/null | tr -d '\r' | awk -F, 'NF>=3 && $1!="Node" {print $2, $3; exit}')
    if [ -z "$info" ]; then
      echo "Battery  : No battery detected (Desktop PC)"
      return
    fi
    read -r st cap <<< "$info"
    if [ "$st" == "2" ]; then status="Charging"; elif [ "$st" == "1" ]; then status="Discharging"; else status="AC/Other"; fi
    echo "Battery  : ${cap}% ($status)"
    if [ "${cap:-100}" -le 20 ] && [ "$st" == "1" ]; then
      warn "Battery charge is low (${cap}%)"
      log "HEALTH WARNING: low battery ${cap}%"
    else
      ok "Battery health is normal"
    fi
  else
    echo "Battery  : No battery info available"
  fi
}

check_ssd() {
  if command -v smartctl >/dev/null 2>&1; then
    found=0
    for dev in /dev/sd? /dev/nvme?n?; do
      [ -b "$dev" ] || continue
      found=1
      res=$(sudo -n smartctl -H "$dev" 2>/dev/null | awk -F: '/SMART overall-health|SMART Health Status/ {gsub(/^ +/,"",$2); print $2}')
      res=${res:-Unknown}
      echo "Drive    : $dev (SMART: $res)"
      if [[ "$res" == *"PASSED"* || "$res" == *"OK"* ]]; then
        ok "Drive $dev SMART health passed"
      elif [ "$res" == "Unknown" ]; then
        warn "Run with sudo for SMART check on $dev"
      else
        warn "Drive $dev SMART health: $res"
        log "HEALTH WARNING: drive $dev SMART $res"
      fi
    done
    [ "$found" -eq 0 ] && echo "SSD/Disk : No physical drives found"
  elif [ -d /sys/block ]; then
    found=0
    for d in /sys/block/sd* /sys/block/nvme*; do
      [ -d "$d" ] || continue
      found=1
      name=$(basename "$d")
      rot=$(cat "$d/queue/rotational" 2>/dev/null)
      [ "$rot" == "0" ] && dtype="SSD" || dtype="HDD/Disk"
      state=$(cat "$d/device/state" 2>/dev/null)
      state=${state:-active}
      echo "Drive    : $name ($dtype, state: $state)"
      if [[ "$state" == "running" || "$state" == "live" || "$state" == "active" ]]; then
        ok "Drive $name ($dtype) is healthy"
      else
        warn "Drive $name ($dtype) state is $state"
        log "HEALTH WARNING: drive $name state $state"
      fi
    done
    [ "$found" -eq 0 ] && echo "SSD/Disk : No physical drives found"
  elif command -v wmic >/dev/null 2>&1; then
    disks=$(wmic diskdrive get Model,Status /format:csv 2>/dev/null | tr -d '\r' | awk -F, 'NF>=3 && $1!="Node" {print $2 "|" $3}')
    if [ -z "$disks" ]; then
      echo "SSD/Disk : No disk health data found"
      return
    fi
    while IFS='|' read -r model status; do
      echo "Drive    : $model (Status: $status)"
      if [ "$status" == "OK" ]; then
        ok "Drive '$model' is healthy"
      else
        warn "Drive '$model' status is $status"
        log "HEALTH WARNING: drive $model status $status"
      fi
    done <<< "$disks"
  else
    echo "SSD/Disk : Disk health check not supported"
  fi
}

health_check() {
  title "SYSTEM HEALTH"
  echo "Hostname : $(hostname)"
  echo "Uptime   : $(get_uptime)"
  echo "Kernel   : $(uname -r)"

  cores=$(nproc)
  load=$(cut -d' ' -f1 /proc/loadavg)
  echo "CPU load : $load (cores: $cores)"
  if awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'; then
    warn "CPU is overloaded"
    log "HEALTH WARNING: high CPU load $load"
  else
    ok "CPU load is normal"
  fi

  mem=$(get_mem_pct)
  mem=${mem:-0}
  echo "Memory   : ${mem}% used"
  if [ "$mem" -ge "$MEM_LIMIT" ]; then
    warn "Memory usage is high"
    log "HEALTH WARNING: memory ${mem}%"
  else
    ok "Memory usage is normal"
  fi

  root=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
  echo "Disk (/) : ${root}% used"
  if [ "$root" -ge "$DISK_LIMIT" ]; then
    warn "Root disk is nearly full"
    log "HEALTH WARNING: root disk ${root}%"
  else
    ok "Disk usage is normal"
  fi

  check_battery
  check_ssd
  log "Health check run"
}

save_report() {
  file="$REPORT_DIR/report_$(date +%F_%H%M%S).txt"
  {
    echo "SYSTEM REPORT - $(date)"
    echo "----------------------------------"
    if command -v uptime >/dev/null 2>&1; then uptime; else echo "Uptime: $(get_uptime)"; fi
    echo; if command -v free >/dev/null 2>&1; then free -h; else echo "Memory: $(get_mem_pct)% used"; fi
    echo; df -h -x tmpfs -x devtmpfs -x squashfs
    echo; echo "Top 5 CPU processes:"
    top_cpu_procs
    echo; echo "Logged-in users:"
    users_out=$(who 2>/dev/null)
    if [ -n "$users_out" ]; then echo "$users_out"; else whoami; fi
  } > "$file"
  ok "Report saved: $file"
  log "Report saved: $file"
}

# --- 7. User Management ---
win_user_action() {
  local action="$1" u cur_user="${USER:-$USERNAME}"
  if ! net session >/dev/null 2>&1; then
    err "Windows requires Administrator rights. Right-click Git Bash -> Run as administrator"
    return
  fi

  case $action in
    2) read -rp "New username: " u
       if ! [[ "$u" =~ ^[a-zA-Z0-9._-]{1,20}$ ]]; then err "Invalid username"; return; fi
       if MSYS_NO_PATHCONV=1 net user "$u" >/dev/null 2>&1; then err "User already exists"; return; fi
       read -rsp "Password for $u: " p; echo
       MSYS_NO_PATHCONV=1 net user "$u" "$p" /add >/dev/null &&
         { ok "User $u created"; log "User added: $u"; } || err "Failed to create user $u" ;;
    3) read -rp "Username to delete: " u
       if [ "${u,,}" == "${cur_user,,}" ]; then err "You cannot delete yourself"; return; fi
       if ! MSYS_NO_PATHCONV=1 net user "$u" >/dev/null 2>&1; then err "No such user"; return; fi
       if confirm "Delete Windows user $u?"; then
         MSYS_NO_PATHCONV=1 net user "$u" /delete >/dev/null &&
           { ok "User $u deleted"; log "User deleted: $u"; } || err "Failed to delete user $u"
       fi ;;
    4) read -rp "Username to lock: " u
       if [ "${u,,}" == "${cur_user,,}" ]; then err "You cannot lock yourself"; return; fi
       if ! MSYS_NO_PATHCONV=1 net user "$u" >/dev/null 2>&1; then err "No such user"; return; fi
       MSYS_NO_PATHCONV=1 net user "$u" /active:no >/dev/null &&
         { ok "$u locked"; log "User locked: $u"; } || err "Failed to lock $u" ;;
    5) read -rp "Username to unlock: " u
       if ! MSYS_NO_PATHCONV=1 net user "$u" >/dev/null 2>&1; then err "No such user"; return; fi
       MSYS_NO_PATHCONV=1 net user "$u" /active:yes >/dev/null &&
         { ok "$u unlocked"; log "User unlocked: $u"; } || err "Failed to unlock $u" ;;
  esac
}

list_linux_users() {
  local users
  users=$(awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd)
  if [ "$(echo "$users" | wc -l)" -le 1 ] && [ "$users" == "$USER" ]; then
    local st
    st=$(passwd -S "$USER" 2>/dev/null | awk '{print ($2=="L" || $2=="LK") ? "locked" : "unlocked"}')
    echo " - $USER (${st:-unlocked})"
  else
    sudo awk -F: 'NR==FNR {st[$1]=($2 ~ /^!/ ? "locked" : "unlocked"); next} $3>=1000 && $3<65534 {print " - "$1" ("(st[$1]?st[$1]:"unlocked")")"}' /etc/shadow /etc/passwd 2>/dev/null ||
      awk -F: '$3>=1000 && $3<65534 {print " - "$1}' /etc/passwd
  fi
}

user_menu() {
  title "USER MANAGEMENT"
  echo "1) List users   2) Add user   3) Delete user"
  echo "4) Lock user    5) Unlock user"
  read -rp "Choose: " c

  if [[ "$c" =~ ^[2-5]$ ]] && ! command -v useradd >/dev/null 2>&1; then
    if command -v net >/dev/null 2>&1; then
      win_user_action "$c"
    else
      err "User management is not supported on this system"
    fi
    return
  fi

  case $c in
    1) echo "Normal users on this system:"
       if [ -f /etc/passwd ]; then
         list_linux_users
       elif command -v wmic >/dev/null 2>&1; then
         wmic useraccount where "LocalAccount=True" get Name,Disabled /format:csv 2>/dev/null | tr -d '\r' |
           awk -F, 'NF>=3 && $1!="Node" {state=($2=="FALSE"?"unlocked":"locked"); print " - "$3" ("state")"}'
       elif command -v mkpasswd >/dev/null 2>&1; then
         mkpasswd -l | awk -F: '$3>=197000 && $7=="/usr/bin/bash" {print " - "$1}'
       else
         err "User list not supported on this system"
       fi ;;
    2) read -rp "New username: " u
       if ! [[ "$u" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then err "Invalid username"; return; fi
       if id "$u" &>/dev/null; then err "User already exists"; return; fi
       sudo useradd -m -s /bin/bash "$u" && sudo passwd "$u" &&
         { ok "User $u created"; log "User added: $u"; } ;;
    3) read -rp "Username to delete: " u
       if [ "$u" == "$USER" ]; then err "You cannot delete yourself"; return; fi
       if ! id "$u" &>/dev/null; then err "No such user"; return; fi
       if confirm "Delete $u and their home folder?"; then
         sudo -k userdel -r "$u" && { ok "User $u deleted"; log "User deleted: $u"; }
       fi ;;
    4) read -rp "Username to lock: " u
       if [ "$u" == "$USER" ]; then err "You cannot lock yourself"; return; fi
       if ! id "$u" &>/dev/null; then err "No such user"; return; fi
       sudo -k usermod -L "$u" && { ok "$u locked"; log "User locked: $u"; } ;;
    5) read -rp "Username to unlock: " u
       if ! id "$u" &>/dev/null; then err "No such user"; return; fi
       sudo -k usermod -U "$u" && { ok "$u unlocked"; log "User unlocked: $u"; } ;;
    *) err "Invalid option" ;;
  esac
}

# --- 8. Network Tools ---
network_menu() {
  title "NETWORK TOOLS"
  echo "1) Show IP addresses   2) Test internet (ping)   3) Show open ports"
  read -rp "Choose: " c
  case $c in
    1) if command -v ip >/dev/null 2>&1; then
         ip -brief addr
       elif command -v ipconfig >/dev/null 2>&1; then
         ipconfig
       else
         err "No IP tool found"
       fi ;;
    2) if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
         ping -n 3 -w 2000 8.8.8.8 > /dev/null 2>&1
       else
         ping -c 3 -W 2 8.8.8.8 > /dev/null 2>&1
       fi
       if [ $? -eq 0 ]; then
         ok "Internet is reachable"
       else
         err "No internet connection"
         log "NETWORK: ping failed"
       fi ;;
    3) if command -v ss >/dev/null 2>&1; then
         ss -tuln
       elif command -v netstat >/dev/null 2>&1; then
         netstat -an | tr -d '\r' | awk '/Proto|LISTENING/'
       else
         err "No port checking tool found"
       fi ;;
    *) err "Invalid option" ;;
  esac
  log "Network tool used"
}

# --- 9. View Log File ---
view_log() {
  title "LAST 20 LOG ENTRIES"
  if [ -f "$LOG_FILE" ]; then
    tail -20 "$LOG_FILE"
  else
    echo "Log is empty."
  fi
}

# --- 10. Auto Mode (for cron) ---
if [ "$1" == "--auto" ]; then
  disk_monitor > /dev/null
  health_check > /dev/null
  save_report  > /dev/null
  log "Auto mode finished"
  exit 0
fi

# --- 11. Main Menu Loop ---
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