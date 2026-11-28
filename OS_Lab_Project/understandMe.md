# 📗 understandMe.md — Complete Beginner's Guide, Usage & Viva Prep

> **Welcome!**  
> This guide explains every single line of [`toolkit.sh`](file:///f:/Fall-2026/OS_Lab_Project/toolkit.sh) (Lines 1–551) in **simple, everyday English**, shows you **how to run every option step by step**, and gives you **Viva Questions & Answers** for your OS Lab exam.

---

## 📌 Table of Contents

1. [What Is This Project?](#1-what-is-this-project)
2. [How to Run the Script (Option by Option)](#2-how-to-run-the-script-option-by-option)
3. [Line-by-Line Code Explanation (Lines 1–551)](#3-line-by-line-code-explanation-lines-1551)
   - [Header & Shebang (Lines 1–4)](#header--shebang-lines-14)
   - [Section 1: Settings (Lines 6–15)](#section-1-settings-lines-615)
   - [Section 2: Colors and Helper Functions (Lines 17–30)](#section-2-colors-and-helper-functions-lines-1730)
   - [Section 3: Disk Monitoring (Lines 32–55)](#section-3-disk-monitoring-lines-3255)
   - [Section 4: Backup Automation (Lines 57–126)](#section-4-backup-automation-lines-57126)
   - [Section 5: Process Management (Lines 128–185)](#section-5-process-management-lines-128185)
   - [Section 6: System Health Check & Save Report (Lines 187–368)](#section-6-system-health-check--save-report-lines-187368)
   - [Section 7: User Management (Lines 370–464)](#section-7-user-management-lines-370464)
   - [Section 8: Network Tools (Lines 466–500)](#section-8-network-tools-lines-466500)
   - [Section 9: View Log File (Lines 502–510)](#section-9-view-log-file-lines-502510)
   - [Section 10: Auto Mode for Cron (Lines 512–519)](#section-10-auto-mode-for-cron-lines-512519)
   - [Section 11: Main Menu Loop (Lines 521–551)](#section-11-main-menu-loop-lines-521551)
4. [OS Lab Viva Questions & Easy Answers](#4-os-lab-viva-questions--easy-answers)

---

## 1. What Is This Project?

**SysAdmin Toolkit** (`toolkit.sh`) is an **all-in-one Linux control menu**.  
Instead of typing long Linux commands by hand every day, you run one script and pick a number from `1` to `9` — just like using a TV remote control!

```text
toolkit.sh (551 lines)
├── Lines 1–4     : Script title & #!/bin/bash
├── Lines 6–15    : Settings (folders & warning limits)
├── Lines 17–30   : Colors & small helper functions
├── Lines 32–510  : Feature functions (Menu Options 1 to 8)
├── Lines 512–519 : Auto Mode (--auto for cron)
└── Lines 521–551 : Main Menu Loop (Menu + Option 9 Exit)
```

---

## 2. How to Run the Script (Option by Option)

### First-Time Setup

Open your terminal (**Ubuntu / WSL** or **Git Bash**) and run:

```bash
# Step 1: Go to your project folder
cd /mnt/f/Fall-2026/OS_Lab_Project     # On Git Bash use: cd /f/Fall-2026/OS_Lab_Project

# Step 2: Give run permission
chmod +x toolkit.sh

# Step 3: Start the toolkit
./toolkit.sh
```

You will see the Main Menu:
```text
==============================================
        SYSADMIN TOOLKIT  -  Main Menu
==============================================
 1) Disk monitoring
 2) Backup automation
 3) Process management
 4) System health check
 5) Save system report
 6) User management
 7) Network tools
 8) View log file
 9) Exit
Choose an option [1-9]:
```

---

### Option 1 — Disk Monitoring
1. Type `1` and press **Enter**.
2. **What happens:**
   - Shows a table of all your disk drives (`Size`, `Used`, `Avail`, `Use%`).
   - Checks each drive against `80%`: prints `[OK]` in green if safe, or `[WARNING]` in yellow if `80%` or higher.
   - Scans your `$HOME` folder and prints the **Top 5 biggest folders**.
3. Press **Enter** to return to the menu.

---

### Option 2 — Backup Automation
1. Type `2` and press **Enter**. You see 4 sub-options:
   - **`1` Create backup:** Type a folder path (example: `~/Documents` or `/mnt/f/Fall-2026/OS_Lab_Project`). It saves a compressed `.tar.gz` file inside `~/sysadmin_toolkit/backups/`.
   - **`2` List backups:** Shows all saved `.tar.gz` backup files and their sizes.
   - **`3` Restore backup:** Shows a numbered list (`1`, `2`, ...). Type a number to unpack that backup safely into `~/sysadmin_toolkit/restored/`.
   - **`4` Delete old backups:** Finds backups older than `7` days (`KEEP_DAYS`). If any exist, asks `(y/n)` before deleting them.

---

### Option 3 — Process Management
1. Type `3` and press **Enter**. You see 4 sub-options:
   - **`1` Top 5 CPU processes:** Shows the 5 programs using the most processor power.
   - **`2` Top 5 memory processes:** Shows the 5 programs using the most RAM.
   - **`3` Search a process:** Type a program name (example: `bash` or `python`). Shows matching running programs and their PIDs.
   - **`4` Kill a process:** Type the **PID** (Process ID number) you want to stop, then type `y` to confirm.

---

### Option 4 — System Health Check
1. Type `4` and press **Enter**.
2. **What happens:** Displays your computer's vital signs:
   - Computer name (`Hostname`), how long it has been ON (`Uptime`), and Linux `Kernel` version.
   - **CPU load** compared to your number of CPU cores (`[OK]` or `[WARNING]`).
   - **Memory (RAM) %** compared to `80%` (`[OK]` or `[WARNING]`).
   - **Root Disk `/` %** compared to `80%` (`[OK]` or `[WARNING]`).
   - **Battery Health & Charge:** Charge %, Charging/Discharging state, and battery health % (on Linux/WSL) or Windows battery status (`wmic`).
   - **SSD / Disk Hardware Health:** Drive SMART status (`smartctl`), Linux block device state (`/sys/block`), or Windows drive health (`wmic diskdrive`).

---

### Option 5 — Save System Report
1. Type `5` and press **Enter**.
2. **What happens:** Saves a complete snapshot of `uptime`, RAM, disk drives, top 5 CPU programs, and logged-in users into a text file inside `~/sysadmin_toolkit/reports/` (for example: `report_2026-11-27_223000.txt`).

---

### Option 6 — User Management *(Linux `sudo` / Windows Git Bash `Run as administrator`)*
> ⚠️ Note: On **Ubuntu / WSL**, it uses `sudo useradd`, `userdel`, and `usermod`. On **Windows Git Bash**, it uses `net user` — right-click Git Bash and choose **Run as administrator** to add, delete, lock, or unlock Windows users.

1. Type `6` and press **Enter**. You see 5 sub-options:
   - **`1` List users:** Lists all normal human user accounts on Linux.
   - **`2` Add user:** Type a lowercase username (example: `ali_test`), enter your `sudo` password, then set a new password for that user.
   - **`3` Delete user:** Type the username to delete and confirm `(y/n)`. *(You cannot delete yourself!)*
   - **`4` Lock user:** Type a username to temporarily block them from logging in.
   - **`5` Unlock user:** Type a username to allow them to log in again.

---

### Option 7 — Network Tools
1. Type `7` and press **Enter**. You see 3 sub-options:
   - **`1` Show IP addresses:** Displays your network cards and IP addresses.
   - **`2` Test internet (ping):** Sends 3 test signals to `8.8.8.8` (Google DNS) and tells you `[OK] Internet is reachable` or `[ERROR] No internet connection`.
   - **`3` Show open ports:** Lists listening TCP/UDP network ports (e.g., port `22` SSH, port `80` HTTP).

---

### Option 8 — View Log File
1. Type `8` and press **Enter**.
2. **What happens:** Displays the **last 20 lines** of `~/sysadmin_toolkit/toolkit.log` so you can see a history of everything the toolkit did with exact dates and times.

---

### Option 9 — Exit
1. Type `9` and press **Enter**.
2. **What happens:** Writes `Toolkit closed` to the log, prints `Goodbye!`, and stops the script cleanly.

---

### Bonus: Auto Mode (Run Without Menu for Cron)
Run in silent background mode:
```bash
./toolkit.sh --auto
```
It automatically runs **Disk Monitoring + Health Check + Save Report** silently (no menu, no screen clutter), saves the report and log, and exits.

To schedule it automatically every day at **2:00 AM** with `cron`:
```bash
crontab -e
```
Add this line at the bottom:
```text
0 2 * * * /bin/bash /mnt/f/Fall-2026/OS_Lab_Project/toolkit.sh --auto
```

---

## 3. Line-by-Line Code Explanation (Lines 1–551)

---

### Header & Shebang (Lines 1–4)

| Line | Code | Simple Meaning |
|---|---|---|
| **1** | `#!/bin/bash` | Called the **shebang**. It tells Linux: *"Use the Bash interpreter to run this script."* |
| **2–4** | `# SysAdmin Toolkit ...` | Lines starting with `#` are **comments** (human notes). Linux ignores them when running. |

---

### Section 1: Settings (Lines 6–15)

| Line | Code | Simple Meaning |
|---|---|---|
| **7** | `BASE_DIR="$HOME/sysadmin_toolkit"` | Creates a variable (box) called `BASE_DIR` holding the main project folder inside your `$HOME` folder. |
| **8** | `LOG_FILE="$BASE_DIR/toolkit.log"` | Path to the diary file where all actions and warnings are saved. |
| **9** | `BACKUP_DIR="$BASE_DIR/backups"` | Folder where compressed backup files will be stored. |
| **10** | `REPORT_DIR="$BASE_DIR/reports"` | Folder where saved `.txt` system reports will be stored. |
| **11** | `DISK_LIMIT=80` | Warning limit for disk space: warn if a drive is `80%` full or more. |
| **12** | `MEM_LIMIT=80` | Warning limit for RAM: warn if memory usage is `80%` or more. |
| **13** | `KEEP_DAYS=7` | Age limit for backups: backups older than `7` days can be deleted during cleanup. |
| **15** | `mkdir -p "$BACKUP_DIR" "$REPORT_DIR"` | Creates `backups/` and `reports/` folders (and `sysadmin_toolkit/` above them). `-p` prevents errors if they already exist. |

---

### Section 2: Colors and Helper Functions (Lines 17–30)

| Line | Code | Simple Meaning |
|---|---|---|
| **18–22** | `RED='\033[0;31m'` ... `NC='\033[0m'` | Stores terminal color codes: Red, Green, Yellow, Blue, and `NC` (No Color = reset back to normal). |
| **24** | `ok() { echo -e "${GREEN}[OK]${NC} $1"; }` | Helper function `ok`: prints `[OK]` in green followed by whatever message you pass as `$1`. (`-e` enables colors). |
| **25** | `warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }` | Helper function `warn`: prints `[WARNING]` in yellow followed by `$1`. |
| **26** | `err() { echo -e "${RED}[ERROR]${NC} $1"; }` | Helper function `err`: prints `[ERROR]` in red followed by `$1`. |
| **27** | `title() { echo -e "\n${BLUE}===== $1 =====${NC}"; }` | Helper function `title`: prints a blank line (`\n`) and a blue heading `===== TITLE =====`. |
| **28** | `log() { echo "$(date '+%F %T') - $1" >> "$LOG_FILE"; }` | Writes `YYYY-MM-DD HH:MM:SS - message` to the end (`>>`) of `toolkit.log`. |
| **29** | `pause() { echo; read -rp "Press Enter to continue..." _; }` | Prints a blank line and waits until the user presses Enter (`_` discards what was typed). |
| **30** | `confirm() { read -rp "$1 (y/n): " a; [[ "$a" == "y" \|\| "$a" == "Y" ]]; }` | Asks `(y/n)` and stores the answer in `a`. Returns success (true) **only** if `a` is `y` or `Y`. |

---

### Section 3: Disk Monitoring (Lines 32–55)

| Line | Code | Simple Meaning |
|---|---|---|
| **33** | `disk_monitor() {` | Starts the `disk_monitor` function (Option 1). |
| **34** | `title "DISK USAGE"` | Prints the blue section title. |
| **35** | `df -h -x tmpfs -x devtmpfs -x squashfs` | Runs `df` (Disk Free) in human units (`-h` = GB/MB) while hiding fake virtual filesystems (`-x`). |
| **36** | `echo` | Prints an empty line for neat spacing. |
| **39** | `df -P -x ... \| awk 'NR>1 {print $6, $5}' \|` | Gets drives in clean columns (`-P`), skips header (`NR>1`), and prints column 6 (drive path) and column 5 (`%` used). Sends output to the loop below. |
| **40** | `while read -r mount pct; do` | Reads one drive at a time into `mount` (e.g., `/`) and `pct` (e.g., `38%`). |
| **41** | `num=${pct%\%}` | Removes `%` from the end of `pct` so `38%` becomes the plain number `38`. |
| **42** | `if [ "$num" -ge "$DISK_LIMIT" ]; then` | Checks if `num` is Greater than or Equal (`-ge`) to `80`. |
| **43–44** | `warn ...` and `log ...` | If `>= 80%`, prints a yellow warning and writes `DISK WARNING` to the log file. |
| **45–47** | `else ok ... fi` | Otherwise prints green `[OK] / is 38% full`. |
| **48** | `done` | Ends the `while` loop after all drives are checked. |
| **50–52** | `echo` / `"Top 5..."` / `"(Scanning...)"` | Prints a heading and a "please wait" message so the screen does not look frozen while scanning. |
| **53** | `du -h --max-depth=1 --exclude="AppData" "$HOME" 2>/dev/null \| sort -rh \| head -6` | Measures folder sizes 1 level deep in `$HOME` (skipping `AppData` so Windows Git Bash stays fast, hiding errors via `2>/dev/null`), sorts biggest first (`sort -rh`), and keeps top 6 lines (`head -6`). |
| **54–55** | `log "Disk check run"` / `}` | Logs that the disk check ran, and closes the function. |

---

### Section 4: Backup Automation (Lines 57–126)

#### `backup_create()` (Lines 58–74)
| Line | Code | Simple Meaning |
|---|---|---|
| **58–59** | `backup_create() {` / `read -rp ... src` | Starts function and asks the user which folder to back up, saving the answer in `src`. |
| **60** | `src="${src/#\~/$HOME}"` | If `src` starts with `~` (example: `~/Documents`), replaces `~` with your full `$HOME` path. |
| **61–64** | `if [ ! -d "$src" ]; then err ...; return; fi` | Checks if `src` is NOT (`!`) an existing folder (`-d`). If missing, prints an error and stops (`return`). |
| **66** | `file="$BACKUP_DIR/backup_$(basename "$src")_$(date +%F_%H%M%S).tar.gz"` | Creates a unique filename using folder name + date + time (example: `backup_Documents_2026-11-27_223000.tar.gz`). |
| **67** | `if tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")" 2>/dev/null; then` | Compresses (`-c` create, `-z` gzip, `-f` file) the folder cleanly from its parent folder (`-C`). |
| **68–69** | `ok ...` / `log ...` | If `tar` succeeded, prints `[OK]` with the backup size (`du -h`) and saves it in the log. |
| **70–74** | `else err ...; log ...; fi` / `}` | If `tar` failed, prints `[ERROR]`, logs the failure, and closes `backup_create`. |

#### `backup_list()` (Lines 76–80)
| Line | Code | Simple Meaning |
|---|---|---|
| **76–77** | `backup_list() {` / `title "EXISTING BACKUPS"` | Starts function and prints title. |
| **78** | `ls -lh "$BACKUP_DIR" \| tail -n +2` | Lists files with sizes (`-lh`), skipping the first `"total ..."` line (`tail -n +2`). |
| **79–80** | `[ -z "$(ls -A "$BACKUP_DIR")" ] && echo "No backups yet."` / `}` | If the backup folder is empty (`-z`), prints `"No backups yet."`, then closes the function. |

#### `backup_restore()` (Lines 82–98)
| Line | Code | Simple Meaning |
|---|---|---|
| **82–83** | `backup_restore() {` / `files=("$BACKUP_DIR"/*.tar.gz)` | Puts all `.tar.gz` backup file paths into a list (array) named `files`. |
| **84–87** | `if [ ! -e "${files[0]}" ]; then err ...; return; fi` | Checks if the first item actually exists (`-e`). If there are no backups, shows an error and returns. |
| **89–90** | `echo "Choose..."` / `select f in "${files[@]}"; do` | Shows a numbered menu of all backups and waits for the user to pick one into `f`. |
| **91** | `[ -n "$f" ] \|\| { err "Invalid choice"; return; }` | If the user picked a wrong number (`f` is empty), prints error and returns. |
| **92–93** | `dest="$BASE_DIR/restored"` / `mkdir -p "$dest"` | Sets and creates the safe `restored/` folder so live files are never overwritten. |
| **94–98** | `tar -xzf "$f" -C "$dest" && ok ...` / `log ...` / `break` / `done` / `}` | Extracts (`-x` extract, `-z` gunzip, `-f` file) into `restored/`, prints `[OK]`, logs it, exits `select` (`break`), and closes function. |

#### `backup_cleanup()` (Lines 100–113)
| Line | Code | Simple Meaning |
|---|---|---|
| **100–101** | `backup_cleanup() {` / `old=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS")` | Finds all `.tar.gz` backups modified more than `7` days ago (`-mtime +7`) and stores their names in `old`. |
| **102–105** | `if [ -z "$old" ]; then ok ...; return; fi` | If `old` is empty (`-z`), prints `"No backups older than 7 days"` and returns. |
| **107–108** | `echo "$old"` / `if confirm "Delete these old backups?"; then` | Displays the old files and asks `(y/n)` before deleting. |
| **109–113** | `find ... -delete` / `ok ...` / `log ...` / `fi` / `}` | If confirmed, deletes those old files, prints `[OK]`, logs the cleanup, and closes function. |

#### `backup_menu()` (Lines 115–126)
| Line | Code | Simple Meaning |
|---|---|---|
| **115–118** | `backup_menu() {` ... `read -rp "Choose: " c` | Prints the Backup sub-menu and reads the user's choice into `c`. |
| **119–126** | `case $c in 1)..4).. *) err ... esac` / `}` | Calls the matching backup function (`1`–`4`), or shows `[ERROR]` for anything else (`*`). |

---

### Section 5: Process Management (Lines 128–185)

| Line | Code | Simple Meaning |
|---|---|---|
| **129–135** | `top_cpu_procs() { if ps -eo ...; then ps -eo ... \| head -6; else ps -W ...; fi }` | Shared helper: uses Linux `ps -eo ... --sort=-%cpu`, or falls back to `ps -W` / `ps -e` in Git Bash so process lists are never empty. |
| **137–148** | `top_mem_procs() { if ps -eo ...; then ps -eo ...; elif command -v tasklist ...; fi }` | Uses `ps -eo ... --sort=-%mem` on Linux/WSL, or sorts Windows `tasklist` memory usage on Git Bash to show the top 5 RAM processes. |
| **150–154** | `process_menu() {` ... `read -rp "Choose: " c` | Shows the 4 process options and stores user choice in `c`. |
| **155–157** | `case $c in` / `1) top_cpu_procs ;;` / `2) top_mem_procs ;;` | Option 1 & 2 call `top_cpu_procs` / `top_mem_procs`. |
| **158–163** | `3) read -rp "Process name: " n` / `pgrep -a` or `ps -W \| grep -i` | Option 3: Searches running processes using `pgrep -a` (Linux/WSL) or `ps -W \| grep -i` (Git Bash). |
| **164–165** | `4) read -rp "PID to kill: " pid` / `if ! [[ "$pid" =~ ^[0-9]+$ ]] ...` | **Safety Check 1:** Ensures `pid` contains only digits (`0–9`), preventing bad text input. |
| **166–174** | `pname=""` / `ps -p "$pid"` / `tasklist /FI "PID eq $pid"` / `if [ -z "$pname" ]` | **Safety Check 2:** Looks up the process name across Linux `ps`, Git Bash `ps`, or Windows `tasklist` and stops if not found. |
| **175–182** | `if confirm "Really kill process $pid ($pname)?"; then kill ... \|\| taskkill ...; fi` | **Safety Check 3:** Shows `(y/n)` with the process name, then stops it via `kill` (or `taskkill` on Windows PIDs). |
| **183–185** | `*) err "Invalid option" ;;` / `esac` / `}` | Handles invalid choice and closes `process_menu`. |

---

### Section 6: System Health Check & Save Report (Lines 187–368)

#### `get_uptime()` & `get_mem_pct()` (Lines 188–206)
| Line | Code | Simple Meaning |
|---|---|---|
| **188–196** | `get_uptime() { if command -v uptime ...; then uptime -p; elif [ -r /proc/uptime ]; then awk ...; fi }` | Checks if `uptime` command exists (Linux/WSL). If missing (Git Bash), calculates uptime from `/proc/uptime`. |
| **198–206** | `get_mem_pct() { if command -v free ...; then free \| awk ...; elif [ -r /proc/meminfo ]; then awk ...; fi }` | Uses `free` if installed (Linux/WSL), or reads `MemTotal` and `MemFree` from `/proc/meminfo` (Git Bash) to return RAM % used. |

#### `check_battery()` & `check_ssd()` (Lines 208–310)
| Line | Code | Simple Meaning |
|---|---|---|
| **208–252** | `check_battery() { ... }` | Reads `/sys/class/power_supply/BAT*` on Linux/WSL (charge %, status, and health % from `full/design`), or `wmic path Win32_Battery` on Git Bash. Warns if battery health `< 80%` or charge `<= 20%` while discharging. |
| **254–310** | `check_ssd() { ... }` | Checks drive hardware health using `smartctl -H` (Linux SMART), `/sys/block/sd*` & `nvme*` (`rotational=0` means SSD), or `wmic diskdrive get Model,Status` on Git Bash. Warns if any drive reports an unhealthy state. |

#### `health_check()` (Lines 312–350)
| Line | Code | Simple Meaning |
|---|---|---|
| **312–316** | `health_check() {` ... `echo "Hostname/Uptime/Kernel"` | Prints computer name (`hostname`), time ON (`get_uptime`), and kernel version (`uname -r`). |
| **318–320** | `cores=$(nproc)` / `load=$(cut -d' ' -f1 /proc/loadavg)` / `echo ...` | Gets total CPU cores (`nproc`) and 1-minute CPU load average (1st field in `/proc/loadavg`). |
| **321–326** | `if awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'; then ...` | Uses `awk` to compare decimal `load > cores`. Warns and logs if overloaded; otherwise prints `[OK]`. |
| **328–330** | `mem=$(get_mem_pct)` / `mem=${mem:-0}` / `echo ...` | Gets RAM % from `get_mem_pct` (`${mem:-0}` ensures it defaults to `0` if empty so integer check never crashes). |
| **331–336** | `if [ "$mem" -ge "$MEM_LIMIT" ]; then ...` | Compares RAM `%` against `80%`. Warns and logs if high; otherwise prints `[OK]`. |
| **338–339** | `root=$(df / \| awk 'NR==2 {print $5}' \| tr -d '%')` / `echo ...` | Gets root `/` disk `%` from row 2 column 5 of `df /` and deletes `%` (`tr -d '%'`). |
| **340–345** | `if [ "$root" -ge "$DISK_LIMIT" ]; then ...` | Compares root disk `%` against `80%`; warns if full, otherwise prints `[OK]`. |
| **347–350** | `check_battery` / `check_ssd` / `log "Health check run"` / `}` | Runs the battery and SSD health checks, logs `"Health check run"`, and closes `health_check`. |

#### `save_report()` (Lines 352–368)
| Line | Code | Simple Meaning |
|---|---|---|
| **352–353** | `save_report() {` / `file="$REPORT_DIR/report_$(date +%F_%H%M%S).txt"` | Builds a timestamped `.txt` report filename inside `reports/`. |
| **354–365** | `{ echo ...; uptime/get_uptime; free/get_mem_pct; df; top_cpu_procs; who/whoami; } > "$file"` | Groups commands inside `{ ... }` (with safe fallbacks on Git Bash) and saves **all** output into `"$file"`. |
| **366–368** | `ok "Report saved: $file"` / `log ...` / `}` | Prints `[OK]`, logs the saved file path, and closes `save_report`. |

---

### Section 7: User Management (Lines 370–464)

| Line | Code | Simple Meaning |
|---|---|---|
| **371–402** | `win_user_action() { ... }` | Handles Options 2–5 on **Windows Git Bash** using `net user` (`/add`, `/delete`, `/active:no`, `/active:yes`) with `MSYS_NO_PATHCONV=1`, checking first with `net session` that Git Bash was opened as Administrator. |
| **404–415** | `list_linux_users() { ... }` | Reads `/etc/passwd` + `/etc/shadow` (or `passwd -S` for `$USER`) and prints each user as ` - username (locked)` or `(unlocked)`. |
| **417–421** | `user_menu() {` ... `read -rp "Choose: " c` | Displays the 5 user choices and saves your choice in `c`. |
| **423–430** | `if [[ "$c" =~ ^[2-5]$ ]] && ! command -v useradd ...; then win_user_action "$c"; ... fi` | If running on Windows Git Bash (no `useradd`), calls `win_user_action` for choices 2–5. |
| **433–443** | `1) ... if [ -f /etc/passwd ]; then list_linux_users; elif command -v wmic ...; fi ;;` | Option 1: Lists normal human users with `(locked)` / `(unlocked)` status on both Linux/WSL and Windows Git Bash. |
| **444** | `2) read -rp "New username: " u` | Option 2 (Linux/WSL): Asks for the new username. |
| **445** | `if ! [[ "$u" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then err "Invalid username"; return; fi` | Checks the username starts with lowercase/`_` and contains only valid characters (max 31 chars). |
| **446** | `if id "$u" &>/dev/null; then err "User already exists"; return; fi` | Checks if that username already exists (`id "$u"`). |
| **447–448** | `sudo useradd -m -s /bin/bash "$u" && sudo passwd "$u" && { ok ...; log ...; }` | Creates the user with a home folder (`-m`) and Bash shell (`-s /bin/bash`), sets password, then prints `[OK]` and logs it. |
| **449** | `3) read -rp "Username to delete: " u` | Option 3: Asks which user to delete. |
| **450** | `if [ "$u" == "$USER" ]; then err "You cannot delete yourself"; return; fi` | **Safety Guard:** Stops you from deleting your own currently logged-in account (`$USER`). |
| **451** | `if ! id "$u" &>/dev/null; then err "No such user"; return; fi` | Checks that the user actually exists before deleting. |
| **452–454** | `if confirm "Delete $u ...?"; then sudo -k userdel -r "$u" && ...; fi ;;` | Asks `(y/n)`, then requires `sudo` password (`-k`) before deleting the user and their home folder (`userdel -r`). |
| **455–458** | `4) read -rp ... u` / `sudo -k usermod -L "$u" && ... ;;` | Option 4: Checks self-guard and user exists, then requires `sudo` password (`-k`) before locking (`usermod -L`). |
| **459–461** | `5) read -rp ... u` / `sudo -k usermod -U "$u" && ... ;;` | Option 5: Checks user exists, then requires `sudo` password (`-k`) before unlocking (`usermod -U`). |
| **462–464** | `*) err "Invalid option" ;;` / `esac` / `}` | Handles invalid choice and closes `user_menu`. |

---

### Section 8: Network Tools (Lines 466–500)

| Line | Code | Simple Meaning |
|---|---|---|
| **467–470** | `network_menu() {` ... `read -rp "Choose: " c` | Prints the 3 network tools and reads user choice into `c`. |
| **472–478** | `1) if command -v ip ...; then ip -brief addr; elif command -v ipconfig ...; fi ;;` | Option 1: Uses `ip -brief addr` on Linux/WSL, or `ipconfig` on Windows Git Bash to show full adapter and IP details. |
| **479–489** | `2) if [[ "$(uname -s)" == MINGW* ... ]]; then ping -n 3 -w 2000 8.8.8.8; else ping -c 3 -W 2 8.8.8.8; fi ...` | Option 2: Uses Windows `ping -n 3 -w 2000` in Git Bash or Linux `ping -c 3 -W 2` on Linux/WSL to test `8.8.8.8` silently. Prints `[OK]` or `[ERROR]`. |
| **490–496** | `3) if command -v ss ...; then ss -tuln; elif command -v netstat ...; fi ;;` | Option 3: Lists listening ports via `ss -tuln` on Linux/WSL, or `netstat -an` filtered for `LISTENING` ports on Windows Git Bash. |
| **497–500** | `*) err ... ;;` / `esac` / `log "Network tool used"` / `}` | Logs network tool usage and closes `network_menu`. |

---

### Section 9: View Log File (Lines 502–510)

| Line | Code | Simple Meaning |
|---|---|---|
| **503–504** | `view_log() {` / `title "LAST 20 LOG ENTRIES"` | Starts function and prints blue heading. |
| **505–510** | `if [ -f "$LOG_FILE" ]; then tail -20 "$LOG_FILE"; else echo "Log is empty."; fi` / `}` | If `toolkit.log` exists (`-f`), shows its last 20 lines (`tail -20`); otherwise prints `"Log is empty."`. |

---

### Section 10: Auto Mode for Cron (Lines 512–519)

| Line | Code | Simple Meaning |
|---|---|---|
| **513** | `if [ "$1" == "--auto" ]; then` | Checks if the first argument (`$1`) passed when starting the script is `--auto`. |
| **514–516** | `disk_monitor > /dev/null` / `health_check > /dev/null` / `save_report > /dev/null` | Runs disk check, health check, and report saving silently (`> /dev/null` throws away screen output). |
| **517–519** | `log "Auto mode finished"` / `exit 0` / `fi` | Writes `"Auto mode finished"` to the log and exits with code `0` (success), skipping the menu. |

---

### Section 11: Main Menu Loop (Lines 521–551)

| Line | Code | Simple Meaning |
|---|---|---|
| **522** | `while true; do` | Starts an infinite loop so the menu keeps coming back after each task finishes. |
| **523** | `clear` | Clears the terminal screen so the menu looks fresh. |
| **524–535** | `echo -e "${BLUE}===..."` ... `echo " 9) Exit"` | Prints the blue banner and options `1` to `9`. |
| **536** | `read -rp "Choose an option [1-9]: " choice` | Waits for the user to type a number and saves it in `choice`. |
| **538–546** | `case $choice in 1) disk_monitor ;; ... 8) view_log ;;` | Matches the typed number (`1`–`8`) and calls that function. |
| **547** | `9) log "Toolkit closed"; echo "Goodbye!"; exit 0 ;;` | Option 9: Logs exit, prints `Goodbye!`, and stops the script (`exit 0`). |
| **548–549** | `*) err "Invalid option, choose 1-9" ;;` / `esac` | If anything else was typed, prints an error and ends `case`. |
| **550–551** | `pause` / `done` | Waits for Enter (`pause`), then jumps back to line 522 (`while true`) to show the menu again. |

---

## 4. OS Lab Viva Questions & Easy Answers

Practice these questions before your presentation — the answers are short, clear, and directly tied to your code!

### 🔹 Group A: Shell Script Basics

**Q1. What is `#!/bin/bash` on line 1, and why do we need it?**  
> It is called the **shebang**. It tells Linux which interpreter should run the script (`/bin/bash`). Without it, a simpler shell like `sh` might run the script and fail on Bash-only features like `[[ ... ]]`, arrays, and `select`.

**Q2. Why do we run `chmod +x toolkit.sh` before `./toolkit.sh`?**  
> In Linux, a `.sh` extension does not automatically make a file executable. `chmod +x` adds **execute (`x`) permission** so the OS allows `./toolkit.sh` to run directly.

**Q3. Why do we put quotes around variables like `"$BACKUP_DIR"` or `"$src"`?**  
> Quoting protects paths that contain **spaces** (like `My Documents`). Without quotes, Bash splits the path at the space into two separate arguments and commands like `tar` or `mkdir` will fail.

**Q4. What is the difference between `>` and `>>` in your script?**  
> - `>` **overwrites** the file (used in `save_report()` to create a brand-new report file).  
> - `>>` **appends** to the end without deleting old lines (used in `log()` so old log entries stay safe).

**Q5. What does `2>/dev/null` mean?**  
> `2` means **stderr** (error messages), and `/dev/null` is Linux's "black hole". So `2>/dev/null` hides error messages (such as "Permission denied" when scanning folders with `du`) to keep the screen clean.

---

### 🔹 Group B: Disk, Files & Backup

**Q6. What is the difference between `df` and `du` in `disk_monitor()`?**  
> - `df` (**Disk Free**) shows total, used, and free space of **whole disk partitions/drives**.  
> - `du` (**Disk Usage**) calculates the **size of specific folders and files** inside `$HOME`.

**Q7. Why did you use `-x tmpfs -x devtmpfs -x squashfs` with `df`?**  
> Those are temporary/virtual memory filesystems, not real hard drives. Excluding (`-x`) them keeps the disk report clean and focused on real storage.

**Q8. Why did you add `--exclude="AppData"` to `du`?**  
> On Windows Git Bash, `$HOME` points to `C:\Users\username`, which contains a giant `AppData` cache folder with thousands of tiny files that makes `du` stall for minutes. Excluding `AppData` keeps the scan fast (a few seconds) and is harmlessly ignored on Ubuntu/Linux.

**Q9. Explain the flags in `tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")"`.**  
> - `-c`: **C**reate a new archive  
> - `-z`: Compress with **g**zip (`.tar.gz`)  
> - `-f`: Specify the output **f**ile name  
> - `-C`: **C**hange into the parent folder first so absolute paths are not stored inside the archive.

**Q10. How does `backup_cleanup()` delete old backups?**  
> It uses `find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete`. `-mtime +7` matches files modified more than 7 days ago, and it always asks `confirm()` `(y/n)` before deleting.

---

### 🔹 Group C: Processes, Signals & System Health

**Q11. What signal does `kill "$pid"` send by default?**  
> It sends **`SIGTERM` (Signal 15)** — a polite request asking the program to save and close cleanly. (`kill -9` sends `SIGKILL`, which forces an immediate kill without cleanup).

**Q12. What safety checks does your script do before killing a process?**  
> Three checks:  
> 1. `[[ "$pid" =~ ^[0-9]+$ ]]` checks the PID is only numbers.  
> 2. `ps -p "$pid" > /dev/null` checks that a process with that PID actually exists.  
> 3. `confirm(...)` asks `(y/n)` showing the process name before sending `kill`.

**Q13. How does `health_check()` check CPU overload without external tools?**  
> It reads the 1-minute CPU load average from `/proc/loadavg` (a virtual kernel file) using `cut -d' ' -f1 /proc/loadavg` and compares it against the number of CPU cores (`nproc`) using `awk`. If `load > cores`, it shows a warning.

**Q14. How does `health_check()` calculate RAM usage percentage?**  
> It runs `free | awk '/Mem:/ {printf "%.0f", $3/$2*100}'` — dividing used memory (`$3`) by total memory (`$2`) and multiplying by `100`.

---

### 🔹 Group D: Users, Network, Security & Cron

**Q15. Why does `user_menu()` filter `/etc/passwd` with `$3>=1000 && $3<65534`?**  
> In `/etc/passwd`, column 3 (`$3`) is the User ID (**UID**). UIDs below `1000` are reserved for Linux background/system accounts (like `daemon`, `www-data`). Regular human user accounts start at UID `1000`.

**Q16. How do you prevent an admin from deleting themselves?**  
> With `[ "$u" == "$USER" ]` — `$USER` is the currently logged-in username, so if they type their own name, the script refuses with an error.

**Q17. What do `ip -brief addr`, `ping -c 3 -W 2 8.8.8.8`, and `ss -tuln` do?**  
> - `ip -brief addr`: Shows network interfaces and IP addresses in short form.  
> - `ping -c 3 -W 2 8.8.8.8`: Sends 3 test packets (max 2s wait each) to Google DNS to check internet access.  
> - `ss -tuln`: Shows listening (`-l`) TCP (`-t`) and UDP (`-u`) ports using numeric ports (`-n`). `ss` is the modern, faster replacement for `netstat`.

**Q18. How does `--auto` mode work with `cron`?**  
> When launched as `./toolkit.sh --auto`, `$1` equals `"--auto"`, so lines 513–519 run `disk_monitor`, `health_check`, and `save_report` silently (`> /dev/null`), log `"Auto mode finished"`, and exit with `0` without opening the menu. In `crontab -e`, `0 2 * * *` runs it automatically every day at **2:00 AM**.
