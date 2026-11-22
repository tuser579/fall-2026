#!/bin/bash
# =====================================================================
#  SYSADMIN TOOLKIT  -  Shell Script Project
#
#  What this script does:
#    It is like a "remote control" for your Linux computer.
#    Instead of typing many commands, you just press a number.
#    It can:
#      - Check how full your hard disk is
#      - Make backup copies of your folders
#      - Show which programs are running and stop them if needed
#      - Check if the computer is healthy (CPU, RAM, Disk)
#      - Save a report of the system state into a file
#      - Create and delete user accounts
#      - Check if the internet is working
#      - Show what actions were taken in the past (the log)
#
#  How to run it:
#      ./toolkit.sh           <- shows the menu, you choose what to do
#      ./toolkit.sh --auto    <- runs silently (good for scheduled tasks)
# =====================================================================


# =====================================================================
# PART A — SETTINGS
# Here we set up folder paths and warning limits.
# A "variable" is just a labelled box that stores a value.
# We write:   BOX_NAME="value"
# We read it: $BOX_NAME
# =====================================================================

# This is the main folder where the toolkit stores all its files.
# $HOME automatically becomes your home folder (e.g. /home/tuser)
BASE_DIR="$HOME/sysadmin_toolkit"

# The log file — every action the script takes is recorded here.
# Think of it like a diary that never forgets.
LOG_FILE="$BASE_DIR/toolkit.log"

# The folder where backup ZIP files will be saved.
BACKUP_DIR="$BASE_DIR/backups"

# The folder where system reports (text snapshots) will be saved.
REPORT_DIR="$BASE_DIR/reports"

# If a disk is this % full or more, show a yellow WARNING.
DISK_LIMIT=80

# If RAM (memory) is this % used or more, show a yellow WARNING.
MEM_LIMIT=80

# Backups older than this many days can be cleaned up / deleted.
KEEP_DAYS=7

# Create the backups/ and reports/ folders if they do not exist yet.
# mkdir = make directory (create folder)
# -p    = do not complain if the folder already exists; also create parent folders
mkdir -p "$BACKUP_DIR" "$REPORT_DIR"


# =====================================================================
# PART B — COLORS AND HELPER FUNCTIONS
# A "function" is a small named block of code you can run any time
# by writing its name.  Think of it as a shortcut you define once.
# =====================================================================

# --- Color codes ---
# These special codes change the color of text in the terminal.
# They look strange but each one just means "switch to this color".
RED='\033[0;31m'     # Red   — used for ERROR messages
GREEN='\033[0;32m'   # Green — used for OK / success messages
YELLOW='\033[1;33m'  # Yellow — used for WARNING messages
BLUE='\033[0;34m'    # Blue  — used for section titles
NC='\033[0m'         # No Color — resets the color back to normal white

# --- Status message functions ---

# ok "message"   → prints:  [OK] message   in GREEN
ok() {
    echo -e "${GREEN}[OK]${NC} $1"
    # $1 means "the first word or sentence passed to this function"
    # Example:  ok "Disk is fine"   →   $1 = "Disk is fine"
}

# warn "message" → prints:  [WARNING] message   in YELLOW
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# err "message"  → prints:  [ERROR] message   in RED
err() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# title "message" → prints a colored section header with ===== around it
title() {
    echo -e "\n${BLUE}===== $1 =====${NC}"
}

# --- Logger function ---
# Every time the script does something important, it calls:
#   log "some description"
# This writes a line into toolkit.log with the current date and time.
log() {
    # date '+%F %T'  gives the current date and time, e.g.:  2026-11-09 14:30:05
    # >>             means APPEND — add to the end of the file without deleting old lines
    echo "$(date '+%F %T') - $1" >> "$LOG_FILE"
}

# --- Pause function ---
# After each menu option finishes, we pause so the user can read the output.
# It just waits until the user presses Enter.
pause() {
    echo
    read -rp "Press Enter to continue..." _
}

# --- Confirm function ---
# Before doing anything dangerous (like deleting files), we ask "are you sure?".
# Usage:   confirm "Are you sure?"
# If the user types  y  or  Y  → the function returns "yes" (success).
# If the user types anything else → it returns "no" (failure).
confirm() {
    read -rp "$1 (y/n): " a
    [[ "$a" == "y" || "$a" == "Y" ]]
}


# =====================================================================
# PART C — MENU OPTION FUNCTIONS
# Each option in the main menu has its own function below.
# When you pick option 1, the script calls disk_monitor().
# When you pick option 2, it calls backup_menu(). And so on.
# =====================================================================


# ---------------------------------------------------------------------
# OPTION 1 — DISK MONITORING
# Shows how full each disk/partition is and warns if it is too full.
# Analogy: like looking at the storage meter on your phone.
# ---------------------------------------------------------------------
disk_monitor() {

    title "DISK USAGE"

    # df = Disk Free — lists all disk drives and their space usage
    # -h = human readable: shows "50G" instead of raw bytes like "53687091200"
    # -x tmpfs -x devtmpfs -x squashfs = exclude fake/virtual drives (they are not real storage)
    df -h -x tmpfs -x devtmpfs -x squashfs

    echo   # print a blank line for spacing

    # Now check each drive one by one and compare with our limit.
    # df -P = same as df but in a "POSIX" (consistent column) format
    # awk 'NR>1 {print $6, $5}' = skip the header row (NR>1 means "row number > 1")
    #                              print column 6 (mount point like "/") and column 5 (percent like "38%")
    df -P -x tmpfs -x devtmpfs -x squashfs | awk 'NR>1 {print $6, $5}' |

    # Read each line from the awk output.
    # mount = the drive name, e.g.:  /
    # pct   = the percentage, e.g.:  38%
    while read -r mount pct; do

        # Strip the % sign from "38%" to get the plain number "38"
        # ${pct%\%}  means: take $pct and remove the % from the end
        num=${pct%\%}

        # -ge means "greater than or equal to" (same as >= in math)
        if [ "$num" -ge "$DISK_LIMIT" ]; then
            # The disk is at or over the warning limit
            warn "$mount is ${num}% full (limit ${DISK_LIMIT}%)"
            log "DISK WARNING: $mount ${num}%"
        else
            # The disk is fine
            ok "$mount is ${num}% full"
        fi

    done

    echo

    # Show the 5 biggest folders inside the home directory
    # du = Disk Usage — shows how much space a folder takes
    # --max-depth=1 = only look one level deep, not into every sub-folder
    # sort -rh = sort from biggest to smallest (-r = reverse, -h = human-readable numbers)
    # head -6   = show only the top 6 results (1 total line + 5 folders)
    # 2>/dev/null = hide any "permission denied" error messages
    echo "Top 5 biggest folders in your home directory:"
    du -h --max-depth=1 "$HOME" 2>/dev/null | sort -rh | head -6

    # Record in the log that the disk check was run
    log "Disk check run"
}


# ---------------------------------------------------------------------
# OPTION 2 — BACKUP AUTOMATION
# backup_create()  : zip a folder and save it
# backup_list()    : show all existing backups
# backup_restore() : extract a backup into a restore folder
# backup_cleanup() : delete backups older than KEEP_DAYS days
# backup_menu()    : shows the sub-menu and calls the right function above
# Analogy: like making a photocopy of an important document and keeping it safe.
# ---------------------------------------------------------------------

# Sub-option 1: Create a compressed backup of a folder
backup_create() {

    # Ask the user which folder to back up
    read -rp "Folder to back up (example: ~/Documents): " src

    # If the user typed ~/Documents, convert the ~ into the actual full path
    # e.g.  ~/Documents  becomes  /home/tuser/Documents
    src="${src/#\~/$HOME}"

    # Check that the folder actually exists; if not, show an error and stop
    if [ ! -d "$src" ]; then
        err "Folder not found: $src"
        return   # "return" exits this function and goes back to the menu
    fi

    # Build the backup filename with the folder name + date + time stamp
    # Example result:  backup_Documents_2026-11-09_143055.tar.gz
    # basename "$src" = just the last part of the path, e.g. "Documents"
    # date +%F_%H%M%S = current date and time like "2026-11-09_143055"
    file="$BACKUP_DIR/backup_$(basename "$src")_$(date +%F_%H%M%S).tar.gz"

    # Create the compressed archive using tar
    # -c = Create a new archive
    # -z = Compress it using gzip (makes it smaller, like a ZIP file)
    # -f = The next thing is the output filename
    # -C = Change into this directory first (keeps paths clean inside the archive)
    # 2>/dev/null = hide any error messages from tar
    if tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")" 2>/dev/null; then
        ok "Backup created: $file ($(du -h "$file" | cut -f1))"
        log "Backup created: $file"
    else
        err "Backup failed"
        log "Backup FAILED for $src"
    fi
}

# Sub-option 2: List all backups that currently exist
backup_list() {
    title "EXISTING BACKUPS"
    # ls -lh = list files with details (-l) and sizes in human-readable format (-h)
    # tail -n +2 = skip the first "total ..." line and show everything below it
    ls -lh "$BACKUP_DIR" | tail -n +2
    # If the backups folder is empty, say so
    [ -z "$(ls -A "$BACKUP_DIR")" ] && echo "No backups yet."
}

# Sub-option 3: Restore a backup (extract it into a restore folder)
backup_restore() {

    # Look for all .tar.gz files in the backup folder
    files=("$BACKUP_DIR"/*.tar.gz)

    # If none found, tell the user and stop
    if [ ! -e "${files[0]}" ]; then
        err "No backups to restore"
        return
    fi

    echo "Choose a backup to restore:"

    # "select" shows a numbered list and waits for the user to pick a number
    select f in "${files[@]}"; do
        # If the user picks an invalid number, f will be empty
        [ -n "$f" ] || { err "Invalid choice"; return; }

        # Create the restore folder if it does not exist
        dest="$BASE_DIR/restored"
        mkdir -p "$dest"

        # Extract the archive into the restore folder
        # tar -xzf = eXtract, unZip gzip, from File
        # -C "$dest" = extract files into the restore folder
        tar -xzf "$f" -C "$dest" && ok "Restored into $dest"
        log "Restored $f"
        break   # exit the select loop after one successful restore
    done
}

# Sub-option 4: Delete backups that are older than KEEP_DAYS days
backup_cleanup() {

    # find = search for files
    # -name "*.tar.gz" = only files whose name ends with .tar.gz
    # -mtime +$KEEP_DAYS = files last modified MORE THAN $KEEP_DAYS days ago
    old=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS")

    # If no old backups were found, tell the user and stop
    if [ -z "$old" ]; then
        ok "No backups older than $KEEP_DAYS days"
        return
    fi

    # Show the user which files will be deleted
    echo "$old"

    # Ask for confirmation before deleting anything
    if confirm "Delete these old backups?"; then
        find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete
        ok "Old backups deleted"
        log "Old backups cleaned"
    fi
}

# The backup sub-menu (shows 4 choices and calls the right function above)
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


# ---------------------------------------------------------------------
# OPTION 3 — PROCESS MANAGEMENT
# Shows running programs and lets you stop (kill) one.
# Analogy: like Windows Task Manager but in the terminal.
# ---------------------------------------------------------------------
process_menu() {

    title "PROCESS MANAGEMENT"
    echo "1) Top 5 CPU processes   2) Top 5 memory processes"
    echo "3) Search a process      4) Kill a process"
    read -rp "Choose: " c

    case $c in

        # Show the 5 programs using the most CPU power
        1)
            # ps = Process Status — lists all currently running programs
            # -eo pid,user,%cpu,%mem,comm = show only these columns:
            #   pid   = Process ID (a unique number for each running program)
            #   user  = who started it
            #   %cpu  = how much CPU (processor) it is using
            #   %mem  = how much RAM (memory) it is using
            #   comm  = the program name
            # --sort=-%cpu = sort by CPU, highest first (- means descending)
            # head -6 = show only 6 lines (1 header row + 5 programs)
            ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
            ;;

        # Show the 5 programs using the most RAM
        2)
            # Same as above but sorted by memory usage instead of CPU
            ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6
            ;;

        # Search for a running process by name
        3)
            read -rp "Process name: " n
            # pgrep = Process Grep — search for a process by its name
            # -a = also show the full command that started it, not just the PID
            # If nothing is found, pgrep returns a failure, so we show a warning
            pgrep -a "$n" || warn "No process found named '$n'"
            ;;

        # Stop (kill) a process by its PID (Process ID)
        4)
            read -rp "PID to kill: " pid

            # Safety check 1: make sure the input is a number, not random text
            # ^[0-9]+$  means: must start (^) and end ($) with only digits (0-9)
            if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
                err "PID must be a number"
                return
            fi

            # Safety check 2: make sure a process with that PID actually exists
            # ps -p "$pid" looks up a specific PID; > /dev/null hides the output
            if ! ps -p "$pid" > /dev/null; then
                err "No such PID"
                return
            fi

            # Safety check 3: ask the user to confirm before killing
            # ps -p "$pid" -o comm= prints just the program name for that PID
            if confirm "Really kill process $pid ($(ps -p "$pid" -o comm=))?"; then
                # kill sends SIGTERM (signal 15) — a polite "please close" message
                # 2>/dev/null hides the error if the process already stopped
                if kill "$pid" 2>/dev/null; then
                    ok "Process $pid stopped"
                    log "Killed PID $pid"
                else
                    err "Could not kill it (it may belong to another user)"
                fi
            fi
            ;;

        *) err "Invalid option" ;;
    esac
}


# ---------------------------------------------------------------------
# OPTION 4 — SYSTEM HEALTH CHECK
# Checks the computer's vital signs: CPU, RAM, and Disk.
# Analogy: like a doctor's check-up for your computer.
# ---------------------------------------------------------------------
health_check() {

    title "SYSTEM HEALTH"

    # hostname = the computer's network name
    echo "Hostname : $(hostname)"

    # uptime -p = how long the computer has been ON, e.g. "up 3 hours, 12 minutes"
    echo "Uptime   : $(uptime -p)"

    # uname -r = the Linux kernel version number
    echo "Kernel   : $(uname -r)"

    # --- CPU Load Check ---

    # nproc = how many CPU cores (processing units) this computer has
    cores=$(nproc)

    # /proc/loadavg is a special virtual file created by the Linux kernel.
    # It always contains the average number of programs waiting for the CPU.
    # cut -d' ' -f1 = take the first number (the 1-minute average load)
    load=$(cut -d' ' -f1 /proc/loadavg)

    echo "CPU load : $load (cores: $cores)"

    # If the load number is greater than the number of cores, the CPU is overwhelmed.
    # We use awk to do this decimal comparison (bash cannot compare decimals directly).
    # awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'
    #   means: exit with failure if load is NOT greater than cores
    if awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'; then
        warn "CPU is overloaded"
        log "HEALTH WARNING: high CPU load $load"
    else
        ok "CPU load is normal"
    fi

    # --- Memory (RAM) Check ---

    # free = shows RAM usage statistics
    # awk '/Mem:/ {printf "%.0f", $3/$2*100}'
    #   /Mem:/     = find the line containing "Mem:"
    #   $3/$2*100  = (used memory / total memory) × 100 = percentage used
    #   printf "%.0f" = round to the nearest whole number (no decimal point)
    mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
    echo "Memory   : ${mem}% used"

    if [ "$mem" -ge "$MEM_LIMIT" ]; then
        warn "Memory usage is high"
        log "HEALTH WARNING: memory ${mem}%"
    else
        ok "Memory usage is normal"
    fi

    # --- Disk Check ---

    # df / = check only the root partition (the main "/" drive)
    # awk 'NR==2 {print $5}' = take the 2nd row and print the 5th column (percent)
    # tr -d '%' = remove the % sign so we get a plain number
    root=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "Disk (/) : ${root}% used"

    if [ "$root" -ge "$DISK_LIMIT" ]; then
        warn "Root disk is nearly full"
        log "HEALTH WARNING: root disk ${root}%"
    else
        ok "Disk usage is normal"
    fi

    log "Health check run"
}


# ---------------------------------------------------------------------
# OPTION 5 — SAVE SYSTEM REPORT
# Runs several commands and saves all their output into one text file.
# Analogy: like a printer that snapshots all health readings into a file.
# ---------------------------------------------------------------------
save_report() {

    # Build the report filename with the current date and time
    # Example:  report_2026-11-09_143055.txt
    file="$REPORT_DIR/report_$(date +%F_%H%M%S).txt"

    # { ... } > "$file"  means: run all the commands inside { }
    # and send ALL their output together into one single file.
    # This is called "output redirection grouping".
    {
        echo "SYSTEM REPORT - $(date)"
        echo "----------------------------------"

        # uptime = shows how long the computer has been ON and the CPU load average
        uptime

        # free -h = shows RAM usage in human-readable sizes (GB, MB)
        echo; free -h

        # df -h = shows disk space for all real drives
        echo; df -h -x tmpfs -x devtmpfs -x squashfs

        # ps = shows the top CPU-using processes
        echo; echo "Top 5 CPU processes:"
        ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6

        # who = shows which users are currently logged in
        echo; echo "Logged-in users:"; who

    } > "$file"   # Everything above is written into the report file

    ok "Report saved: $file"
    log "Report saved: $file"
}
 

# ---------------------------------------------------------------------
# OPTION 6 — USER MANAGEMENT
# Create, delete, lock, unlock user accounts.
# Analogy: like being the HR/IT manager who controls employee logins.
# ---------------------------------------------------------------------
user_menu() {

    title "USER MANAGEMENT"
    echo "1) List users   2) Add user   3) Delete user"
    echo "4) Lock user    5) Unlock user"
    read -rp "Choose: " c

    case $c in

        # Show all real (human) user accounts on this system
        1)
            echo "Normal users on this system:"
            # /etc/passwd = a file that lists every user account (one per line)
            # Each line is split by colons (:). The 3rd field ($3) is the User ID (UID).
            # UIDs below 1000 are system/service accounts (like daemon, www-data).
            # Real human users start from UID 1000 up to 65534.
            # awk -F: = use colon as the separator
            # '$3>=1000 && $3<65534' = only show users with UID in the human range
            awk -F: '$3>=1000 && $3<65534 {print " - "$1}' /etc/passwd
            ;;

        # Create a new user account
        2)
            read -rp "New username: " u

            # Validate the username follows Linux rules:
            # ^[a-z_]         = must start with a lowercase letter or underscore
            # [a-z0-9_-]{0,30}$  = followed by up to 30 lowercase letters, digits, _ or -
            if ! [[ "$u" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then
                err "Invalid username"
                return
            fi

            # Check if this username already exists
            # id "$u" = looks up user info; &>/dev/null = hide all output
            if id "$u" &>/dev/null; then
                err "User already exists"
                return
            fi

            # sudo = run as administrator (needed to create/modify users)
            # useradd = create a new user account
            # -m = also create their home folder /home/username
            # -s /bin/bash = set Bash as their default terminal shell
            sudo useradd -m -s /bin/bash "$u" && sudo passwd "$u" &&
                { ok "User $u created"; log "User added: $u"; }
            ;;

        # Delete a user account and their home folder
        3)
            read -rp "Username to delete: " u

            # Safety guard: prevent deleting the currently logged-in user
            # $USER = the username of whoever is running this script right now
            if [ "$u" == "$USER" ]; then
                err "You cannot delete yourself"
                return
            fi

            # Make sure the user exists before trying to delete them
            if ! id "$u" &>/dev/null; then
                err "No such user"
                return
            fi

            # Ask for confirmation before the irreversible delete
            if confirm "Delete $u and their home folder?"; then
                # userdel -r = delete the user AND their home folder
                sudo userdel -r "$u" && { ok "User $u deleted"; log "User deleted: $u"; }
            fi
            ;;

        # Lock a user account (prevent them from logging in)
        4)
            read -rp "Username to lock: " u
            # usermod -L = Lock: puts a ! before the password so login fails
            sudo usermod -L "$u" && { ok "$u locked"; log "User locked: $u"; }
            ;;

        # Unlock a user account (allow them to log in again)
        5)
            read -rp "Username to unlock: " u
            # usermod -U = Unlock: removes the ! to restore login access
            sudo usermod -U "$u" && { ok "$u unlocked"; log "User unlocked: $u"; }
            ;;

        *) err "Invalid option" ;;
    esac
}


# ---------------------------------------------------------------------
# OPTION 7 — NETWORK TOOLS
# Check network interfaces, test internet, and see open ports.
# Analogy: like a plumber checking if the water pipes are working.
# ---------------------------------------------------------------------
network_menu() {

    title "NETWORK TOOLS"
    echo "1) Show IP addresses   2) Test internet (ping)   3) Show open ports"
    read -rp "Choose: " c

    case $c in

        # Show all network interfaces and their IP addresses
        1)
            # ip -brief addr = shows each network card and its IP address in a short format
            # Example output:
            #   lo         UNKNOWN   127.0.0.1/8     (loopback — your computer to itself)
            #   eth0       UP        172.20.144.1/20  (ethernet — your actual network)
            ip -brief addr
            ;;

        # Test if the internet is reachable by pinging Google's DNS server
        2)
            # ping = sends a small test packet to a remote server and waits for a reply
            # -c 3     = send exactly 3 test packets
            # -W 2     = wait maximum 2 seconds for each reply
            # 8.8.8.8  = Google's public DNS server (always online, great for testing)
            # > /dev/null 2>&1 = throw away all output (we only care if it succeeded or failed)
            if ping -c 3 -W 2 8.8.8.8 > /dev/null 2>&1; then
                ok "Internet is reachable"
            else
                err "No internet connection"
                log "NETWORK: ping failed"
            fi
            ;;

        # Show which ports (doors) on this computer are open and listening
        3)
            # ss = Socket Statistics — shows open network connections/ports
            # -t = TCP connections (the common type used by web, SSH, etc.)
            # -u = UDP connections (used by DNS, games, etc.)
            # -l = only show LISTENING ports (ports waiting for incoming connections)
            # -n = show port numbers (like 22, 80, 443) instead of service names
            # Example output:
            #   tcp  LISTEN  0.0.0.0:22   <- SSH is open
            #   tcp  LISTEN  0.0.0.0:80   <- web server is open
            ss -tuln
            ;;

        *) err "Invalid option" ;;
    esac

    log "Network tool used"
}


# ---------------------------------------------------------------------
# OPTION 8 — VIEW LOG FILE
# Shows the last 20 lines of the toolkit.log diary file.
# Analogy: like reading the last page of a notebook.
# ---------------------------------------------------------------------
view_log() {
    title "LAST 20 LOG ENTRIES"
    if [ -f "$LOG_FILE" ]; then
        # tail = show the LAST lines of a file
        # -20  = show the last 20 lines
        tail -20 "$LOG_FILE"
    else
        echo "Log is empty."
    fi
}


# =====================================================================
# PART D — AUTO MODE AND MAIN MENU LOOP
# =====================================================================


# --- AUTO MODE (for cron scheduled tasks) ---
# When you run:  ./toolkit.sh --auto
# The script skips the menu and runs silently in the background.
# $1 = the first word typed after the script name when you run it
# If $1 equals "--auto" then run the checks and exit.
if [ "$1" == "--auto" ]; then
    # > /dev/null = throw away screen output (run silently)
    disk_monitor > /dev/null
    health_check > /dev/null
    save_report  > /dev/null
    log "Auto mode finished"
    exit 0   # exit the script. 0 means success (no errors).
fi


# --- MAIN MENU LOOP ---
# "while true; do ... done" = an infinite loop that keeps repeating forever.
# It only stops when the user picks Option 9 (Exit).
while true; do

    clear   # clear the screen so the menu looks fresh each time

    # Print the menu header using our BLUE color
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${BLUE}        SYSADMIN TOOLKIT  -  Main Menu${NC}"
    echo -e "${BLUE}==============================================${NC}"

    # Print all the menu options
    echo " 1) Disk monitoring"
    echo " 2) Backup automation"
    echo " 3) Process management"
    echo " 4) System health check"
    echo " 5) Save system report"
    echo " 6) User management"
    echo " 7) Network tools"
    echo " 8) View log file"
    echo " 9) Exit"

    # Wait for the user to type a number and store it in "choice"
    read -rp "Choose an option [1-9]: " choice

    # "case ... in" = like a selector/switch: run the matching option
    # 1) means "if choice == 1"
    # *) means "catch-all: if nothing else matched"
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

    pause   # wait for Enter before showing the menu again

done
