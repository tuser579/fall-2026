# 📗 understandMe.md — SysAdmin Toolkit: A Complete Beginner's Guide

> **Who is this guide for?**  
> This guide is written for someone who has **never written a script before** and may not know much Linux.  
> Every line of code is explained in everyday simple language with real-world examples.  
> Read it from top to bottom and you will understand the whole project completely. ✅

---

## 📌 Table of Contents

1. [What is this project?](#1-what-is-this-project)
2. [What is a Shell Script?](#2-what-is-a-shell-script)
3. [How to run the project](#3-how-to-run-the-project)
4. [How the script is organised](#4-how-the-script-is-organised)
5. [Line-by-Line Code Explanation](#5-line-by-line-code-explanation)
   - [Part A — Settings](#part-a--settings-lines-1120)
   - [Part B — Colors and Helpers](#part-b--colors-and-helpers-lines-2238)
   - [Part C — The 9 Menu Options](#part-c--the-9-menu-options)
     - [Option 1: Disk Monitoring](#option-1-disk-monitoring)
     - [Option 2: Backup Automation](#option-2-backup-automation)
     - [Option 3: Process Management](#option-3-process-management)
     - [Option 4: System Health Check](#option-4-system-health-check)
     - [Option 5: Save Report](#option-5-save-report)
     - [Option 6: User Management](#option-6-user-management)
     - [Option 7: Network Tools](#option-7-network-tools)
     - [Option 8: View Log File](#option-8-view-log-file)
     - [Option 9: Exit](#option-9-exit)
   - [Part D — Auto Mode and the Main Menu Loop](#part-d--auto-mode-and-main-menu-loop)
6. [Automation with Cron](#6-automation-with-cron)
7. [Viva Quick-Answer Sheet](#7-viva-quick-answer-sheet)

---

## 1. What is this project?

Imagine you are the **IT person responsible for looking after a company's computer server**.  
Every day you have to:
- Check if the hard disk is getting full 💾
- Take backups of important folders 📦
- Check if any program is using too much CPU or memory 🔥
- Check if the internet is working 🌐
- Create or delete user accounts for employees 👤

Doing all of this **manually** every day by typing long commands is boring and slow.

**This project solves that problem!**  

`toolkit.sh` is a **menu-driven automation tool** — think of it like a **remote control** for your Linux server. Instead of typing 10 different commands, you just press a number and the script does the work automatically.

When you run the script, you see this menu:

```
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

## 2. What is a Shell Script?

A **shell script** (`.sh` file) is simply a **text file full of Linux commands**.

Imagine writing a shopping list on a paper. When you give that paper to someone, they go to the shop and buy each item one by one.

A shell script works the same way:
- You write commands in a text file (the shopping list).
- When you run the script, Linux reads and executes every command one by one from top to bottom.

The script file is called `toolkit.sh`. The `.sh` at the end just means it is a shell script.

---

## 3. How to Run the Project

Open your **Ubuntu / Linux terminal** and type these commands one by one:

```bash
# Step 1: Go into the project folder
cd /mnt/f/Fall-2026/OS_Lab_Project

# Step 2: Give the script permission to run
chmod +x toolkit.sh

# Step 3: Run it!
./toolkit.sh
```

> 💡 **Tip for Windows users:** In the Ubuntu terminal, to paste anything you copied, just **right-click your mouse** inside the terminal window.

---

## 4. How the Script is Organised

The script is split into **4 clear parts**:

```
toolkit.sh
│
├── PART A — Settings (Variables, Folder paths, Limits)
│
├── PART B — Helpers (Color functions, Logger, Confirm popup)
│
├── PART C — Feature Functions (1 function per menu option)
│            disk_monitor(), backup_create(), health_check() ...
│
└── PART D — Main Menu Loop (shows the menu, calls functions)
             Also handles --auto mode for cron scheduling
```

Think of it like a restaurant:
- **Part A** = The kitchen rules and ingredient inventory.
- **Part B** = Basic kitchen tools (pans, knives, timers).
- **Part C** = Individual recipes (one per dish).
- **Part D** = The waiter who takes your order and calls the right kitchen recipe.

---

## 5. Line-by-Line Code Explanation

---

### Part A — Settings (Lines 11–20)

```bash
BASE_DIR="$HOME/sysadmin_toolkit"
LOG_FILE="$BASE_DIR/toolkit.log"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
DISK_LIMIT=80
MEM_LIMIT=80
KEEP_DAYS=7

mkdir -p "$BACKUP_DIR" "$REPORT_DIR"
```

**What is a variable?**  
A variable is a **labelled box** where you store some information.  
Example: `DISK_LIMIT=80` creates a box labelled `DISK_LIMIT` and puts the value `80` inside it.  
Later in the code, whenever the script needs that limit, it reads from the box using `$DISK_LIMIT`.

| Variable | What it stores | Simple Explanation |
|---|---|---|
| `BASE_DIR` | Main project folder path | Like your project's home address |
| `LOG_FILE` | Path to the log file | Where all actions get recorded (like a diary) |
| `BACKUP_DIR` | Folder for backups | Like a shelf for backup ZIP files |
| `REPORT_DIR` | Folder for reports | Like a filing cabinet for documents |
| `DISK_LIMIT=80` | Warning threshold = 80% | If disk is 80% full → show a yellow warning |
| `MEM_LIMIT=80` | Warning threshold = 80% | If RAM is 80% used → show a yellow warning |
| `KEEP_DAYS=7` | Days before cleanup | Backups older than 7 days can be auto-deleted |

**What is `$HOME`?**  
`$HOME` is a special built-in Linux variable that automatically equals your home directory.  
If your username is `tuser`, then `$HOME` = `/home/tuser`.

**What does `mkdir -p` do?**  
`mkdir` = make directory (create folder).  
`-p` = "parents" — if the folder already exists, don't throw an error. Also create parent folders if they are missing.

So `mkdir -p "$BACKUP_DIR" "$REPORT_DIR"` just creates the `backups/` and `reports/` folders when the script starts, automatically.

---

### Part B — Colors and Helpers (Lines 22–38)

#### Colors

```bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'
```

These are **ANSI escape codes** — special codes that tell the terminal to change the text color.

| Code | Color | Used for |
|---|---|---|
| `RED` | 🔴 Red | Error messages |
| `GREEN` | 🟢 Green | Success messages |
| `YELLOW` | 🟡 Yellow | Warnings |
| `BLUE` | 🔵 Blue | Titles and headers |
| `NC` | ⬜ No Color | Reset back to normal white text |

#### Status Message Functions

```bash
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; }
```

**What is a function?**  
A function is a **small named piece of code** that you can call (run) any time you need it.  
Think of it like a shortcut. Instead of writing the same 5 lines of code 20 times, you write it once inside a function and just call its name.

- `ok "message"` → prints: `[OK] message` in GREEN
- `warn "message"` → prints: `[WARNING] message` in YELLOW
- `err "message"` → prints: `[ERROR] message` in RED

**What does `$1` mean inside a function?**  
`$1` means "the first word/sentence you pass to the function".  
Example: `ok "Disk is fine"` → `$1` = `"Disk is fine"` → prints `[OK] Disk is fine`.

#### The Logger

```bash
log() { echo "$(date '+%F %T') - $1" >> "$LOG_FILE"; }
```

Every time the script does something important, it calls `log "some message"`.

- `date '+%F %T'` = current date and time (e.g. `2026-11-09 14:30:05`)
- `>>` = **append** to file (adds to the end WITHOUT deleting existing content)
- So every action gets written to `toolkit.log` with a timestamp, like a diary.

**Example log file content:**
```
2026-11-09 14:30:05 - Disk check run
2026-11-09 14:31:22 - Backup created: /home/tuser/sysadmin_toolkit/backups/backup_Documents_2026-11-09.tar.gz
2026-11-09 14:32:00 - Health check run
```

#### Confirm (Yes/No) Popup

```bash
confirm() { read -rp "$1 (y/n): " a; [[ "$a" == "y" || "$a" == "Y" ]]; }
```

Before any **dangerous action** (like deleting a backup or deleting a user), the script asks you to confirm.  
If you type `y` or `Y`, it proceeds. If you type `n` or anything else, it cancels.

---

### Part C — The 9 Menu Options

---

### Option 1: Disk Monitoring

**📂 Code location:** Lines 40–59  
**📌 Function name:** `disk_monitor()`

**Real-world analogy:**  
This is like looking at the storage meter on your phone. It tells you how much space is used and warns you if you are running out.

#### Step 1: Show all disk drives

```bash
df -h -x tmpfs -x devtmpfs -x squashfs
```

- `df` = **Disk Free** — a Linux command that lists all mounted drives and their space usage.
- `-h` = **Human readable** — shows sizes in `GB` and `MB` instead of raw byte numbers that are hard to read.
- `-x tmpfs -x devtmpfs -x squashfs` = Exclude fake/virtual drives so the output is clean and simple.

**Example output you will see:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   18G   30G  38% /
```

#### Step 2: Check each drive and warn if too full

```bash
df -P ... | awk 'NR>1 {print $6, $5}' | while read -r mount pct; do
  num=${pct%\%}
  if [ "$num" -ge "$DISK_LIMIT" ]; then
    warn "$mount is ${num}% full"
  else
    ok "$mount is ${num}% full"
  fi
done
```

- `awk 'NR>1 {print $6, $5}'` = Skip the header row (`NR>1`) and print column 6 (mount point like `/`) and column 5 (percentage like `38%`).
- `num=${pct%\%}` = Strips the `%` sign from `38%` to get the pure number `38`.
- `-ge` means **Greater than or Equal to** (the math `>=` symbol).
- If `38 >= 80` → FALSE → prints `[OK] / is 38% full` ✅
- If `91 >= 80` → TRUE → prints `[WARNING] / is 91% full` ⚠️

#### Step 3: Show top 5 biggest folders

```bash
du -h --max-depth=1 "$HOME" 2>/dev/null | sort -rh | head -6
```

- `du` = **Disk Usage** — calculates how much space a folder and its contents take.
- `--max-depth=1` = Only look one level deep (don't go into every sub-sub-folder).
- `sort -rh` = Sort from **biggest to smallest** (`-r` = reverse, `-h` = human readable numbers).
- `head -6` = Show only the top 6 results.
- `2>/dev/null` = Hide any permission error messages so the output stays clean.

---

### Option 2: Backup Automation

**📂 Code location:** Lines 61–117  
**📌 Function name:** `backup_menu()` which calls sub-functions

**Real-world analogy:**  
Backup is like making a photocopy of an important document and keeping it in a safe place. If the original gets damaged, you can restore from the copy.

When you pick Option 2, a sub-menu appears:
```
1) Create backup   2) List backups   3) Restore backup   4) Delete old backups
```

#### Sub-option 1: Create Backup

```bash
read -rp "Folder to back up (example: ~/Documents): " src
src="${src/#\~/$HOME}"
file="$BACKUP_DIR/backup_$(basename "$src")_$(date +%F_%H%M%S).tar.gz"
tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")"
```

**Step by step:**
1. `read -rp "..."` = Ask you to type the folder name. It waits for your input.
2. `src="${src/#\~/$HOME}"` = If you typed `~/Documents`, convert the `~` to your actual home path `/home/tuser/Documents`.
3. Build the backup filename with date and time:  
   e.g. `backup_Documents_2026-11-09_143055.tar.gz`
4. **`tar -czf`** creates the compressed archive:
   - `-c` = Create a new archive
   - `-z` = Compress using **gzip** (makes it smaller, like a ZIP file)
   - `-f` = Specify the output filename
   - `-C dirname` = Go into the parent folder first (so paths inside the archive are clean)

#### Sub-option 2: List Backups

```bash
ls -lh "$BACKUP_DIR" | tail -n +2
```
`ls -lh` = List files with details (`-l`) and human-readable sizes (`-h`).  
`tail -n +2` = Skip the first line (`total ...`) and show everything below it.

#### Sub-option 3: Restore Backup

```bash
select f in "${files[@]}"; do
  tar -xzf "$f" -C "$dest"
  break
done
```

- `select` = Shows a numbered list and waits for you to pick a number.
- `tar -xzf` = **Extract** the archive (`-x` = extract, `-z` = unzip gzip, `-f` = filename).
- `-C "$dest"` = Extract files into the `restored/` folder.

#### Sub-option 4: Delete Old Backups

```bash
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete
```

- `find` = Search for files.
- `-name "*.tar.gz"` = Only look for files ending in `.tar.gz`.
- `-mtime +7` = Files **modified more than 7 days ago**.
- `-delete` = Delete those files.

Before deleting, it always asks `Delete these old backups? (y/n):` to prevent accidents.

---

### Option 3: Process Management

**📂 Code location:** Lines 119–142  
**📌 Function name:** `process_menu()`

**Real-world analogy:**  
This works exactly like the **Windows Task Manager** (`Ctrl + Shift + Esc`). It shows you all running programs and lets you close (kill) any that are misbehaving or slowing your computer down.

Sub-menu:
```
1) Top 5 CPU processes   2) Top 5 memory processes
3) Search a process      4) Kill a process
```

#### Sub-option 1 & 2: Top CPU / Memory Processes

```bash
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
```

- `ps` = **Process Status** — lists all currently running programs.
- `-eo pid,user,%cpu,%mem,comm` = Show only these columns:
  - `pid` = Process ID (a unique number for every running program)
  - `user` = Who started it
  - `%cpu` = How much processor power it is using
  - `%mem` = How much RAM it is using
  - `comm` = The program name
- `--sort=-%cpu` = Sort by CPU usage, highest first (`-` means descending/reversed).
- `head -6` = Show only the top 6 lines (1 header + 5 results).

**Example output:**
```
  PID USER   %CPU %MEM COMMAND
 1234 tuser  45.2  2.1 firefox
  567 tuser  12.4  1.5 code
  ...
```

#### Sub-option 3: Search a Process

```bash
read -rp "Process name: " n
pgrep -a "$n"
```

- `pgrep` = **Process Grep** — searches for processes by name.
- `-a` = Also show the full command line that started the process (not just the PID).
- If nothing is found, it shows `[WARNING] No process found named 'xyz'`.

#### Sub-option 4: Kill a Process

```bash
read -rp "PID to kill: " pid
if ! [[ "$pid" =~ ^[0-9]+$ ]]; then err "PID must be a number"; return; fi
if ! ps -p "$pid" > /dev/null; then err "No such PID"; return; fi
if confirm "Really kill process $pid?"; then
  kill "$pid"
fi
```

**Three safety checks before killing:**
1. ✅ Is the input actually a number? (`^[0-9]+$` = must be only digits)
2. ✅ Does a process with that PID actually exist? (`ps -p "$pid"`)
3. ✅ Does the user confirm with `y`?

If all three pass, `kill "$pid"` sends a **SIGTERM** signal (Signal 15) which politely asks the program to close itself gracefully.

---

### Option 4: System Health Check

**📂 Code location:** Lines 144–177  
**📌 Function name:** `health_check()`

**Real-world analogy:**  
This is like a doctor's check-up for your computer. It checks the vital signs: CPU heartbeat, memory blood levels, and disk space.

```bash
echo "Hostname : $(hostname)"
echo "Uptime   : $(uptime -p)"
echo "Kernel   : $(uname -r)"
```

| Command | What it shows |
|---|---|
| `hostname` | The computer's network name |
| `uptime -p` | How long the computer has been ON (e.g., "up 3 hours, 12 minutes") |
| `uname -r` | The Linux kernel version number |

#### CPU Load Check:

```bash
cores=$(nproc)
load=$(cut -d' ' -f1 /proc/loadavg)
if awk -v l="$load" -v c="$cores" 'BEGIN {exit !(l > c)}'; then
  warn "CPU is overloaded"
fi
```

- `nproc` = Number of CPU cores (e.g., 4).
- `/proc/loadavg` = A special virtual file created by the Linux kernel that shows the average number of active processes waiting for CPU time.
- It reads the first number from that file (1-minute average load).
- **Logic:** If `load > cores` (e.g., load = 5.2 and cores = 4) → CPU is overwhelmed → show WARNING.

#### Memory (RAM) Check:

```bash
mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
```

- `free` = Shows RAM usage statistics.
- `awk '/Mem:/'` = Find only the line that contains "Mem:".
- `$3/$2*100` = `(Used memory / Total memory) * 100` = percentage used.
- If percentage >= 80 → WARNING.

#### Disk Check:

```bash
root=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
```

- `df /` = Check only the root `/` partition.
- `NR==2` = Take the second row (first row is headers).
- `print $5` = Print the 5th column (percentage used).
- `tr -d '%'` = Remove the `%` sign so we get a plain number.

---

### Option 5: Save Report

**📂 Code location:** Lines 179–192  
**📌 Function name:** `save_report()`

**Real-world analogy:**  
Like a printer that takes a snapshot of all the health check readings and saves them into a text file you can keep, email to your manager, or submit to your professor.

```bash
file="$REPORT_DIR/report_$(date +%F_%H%M%S).txt"
{
  echo "SYSTEM REPORT - $(date)"
  uptime
  free -h
  df -h ...
  ps ...
  who
} > "$file"
```

**How the redirection `{ ... } > "$file"` works:**  
Everything between `{` and `}` is a group of commands.  
`> "$file"` takes ALL the output from ALL those commands together and writes it into one single text file.

This is very handy — instead of running each command separately and copying output by hand, the script does it all at once automatically.

**Example report file content:**
```
SYSTEM REPORT - Mon Nov  9 14:30:00 UTC 2026
----------------------------------
 14:30:00 up 3:12, 1 user, load average: 0.24, 0.18, 0.12
              total        used        free
Mem:           7.7G        3.1G        4.6G
...
```

---

### Option 6: User Management

**📂 Code location:** Lines 194–220  
**📌 Function name:** `user_menu()`

**Real-world analogy:**  
Imagine you are the HR manager and also the IT admin. When a new employee joins, you create their computer login. When someone goes on holiday, you temporarily lock their account. When someone leaves the company, you delete their account.

Sub-menu:
```
1) List users   2) Add user   3) Delete user
4) Lock user    5) Unlock user
```

#### Sub-option 1: List Users

```bash
awk -F: '$3>=1000 && $3<65534 {print " - "$1}' /etc/passwd
```

- `/etc/passwd` = A text file in Linux that contains all user accounts (one per line).
- Each line is separated by `:` colons. The 3rd field (`$3`) is the **User ID (UID)** — a unique number for each user.
- **Why >= 1000?** In Linux, UIDs below 1000 are reserved for system/background service accounts (like `daemon`, `www-data`). Real human users start from 1000.
- So this command only shows **real human users**, not system accounts.

#### Sub-option 2: Add User

```bash
if ! [[ "$u" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then err "Invalid username"; return; fi
sudo useradd -m -s /bin/bash "$u"
sudo passwd "$u"
```

1. First validates the username follows Linux rules (lowercase letters, numbers, underscores only, max 30 characters).
2. `sudo useradd -m -s /bin/bash "$u"`:
   - `sudo` = Run as administrator (super user).
   - `useradd` = Create a new user account.
   - `-m` = Also create their home folder `/home/username`.
   - `-s /bin/bash` = Set Bash as their default terminal shell.
3. `sudo passwd "$u"` = Set a password for the new user.

#### Sub-option 3: Delete User — Safety Guards

```bash
if [ "$u" == "$USER" ]; then err "You cannot delete yourself"; return; fi
sudo userdel -r "$u"
```

- `$USER` = Currently logged-in username.
- **Safety guard:** If you accidentally type your own username, the script blocks it immediately with an error.
- `userdel -r` = Delete the user AND their home directory (`-r` = recursive removal of home folder).
- Asks `(y/n)` confirmation before doing anything.

#### Sub-option 4 & 5: Lock and Unlock

```bash
sudo usermod -L "$u"   # Lock
sudo usermod -U "$u"   # Unlock
```

- `usermod` = Modify an existing user account.
- `-L` = **Lock** (puts a `!` before the password hash in `/etc/shadow`, making login impossible).
- `-U` = **Unlock** (removes the `!`, restores login access).

---

### Option 7: Network Tools

**📂 Code location:** Lines 222–238  
**📌 Function name:** `network_menu()`

**Real-world analogy:**  
Checking your network is like a plumber checking if the water pipes in your house are working, what the water pressure is, and if the main water supply is connected.

Sub-menu:
```
1) Show IP addresses   2) Test internet (ping)   3) Show open ports
```

#### Sub-option 1: Show IP Addresses

```bash
ip -brief addr
```

Shows all your network interfaces (WiFi card, Ethernet card, loopback) and their IP addresses.

**Example output:**
```
lo         UNKNOWN   127.0.0.1/8
eth0       UP        172.20.144.1/20
```

- `lo` = Loopback (your computer talking to itself, always `127.0.0.1`)
- `eth0` = Ethernet/network card with its assigned IP address

#### Sub-option 2: Test Internet

```bash
ping -c 3 -W 2 8.8.8.8
```

- `ping` = Sends a small test packet to a remote server and waits for a reply.
- `-c 3` = Send exactly 3 test packets (`-c` = count).
- `-W 2` = Wait maximum 2 seconds for each reply.
- `8.8.8.8` = Google's public DNS server (always available, very reliable for testing).
- If replies come back → `[OK] Internet is reachable` ✅
- If no replies → `[ERROR] No internet connection` ❌

#### Sub-option 3: Show Open Ports

```bash
ss -tuln
```

- `ss` = **Socket Statistics** — shows network connections and listening ports.
- `-t` = TCP ports
- `-u` = UDP ports
- `-l` = Only show **listening** (open/active) ports
- `-n` = Show **numeric** port numbers (e.g., `22`, `80`, `443`) instead of service names

**Example output:**
```
Netid State  Recv-Q Send-Q   Local Address:Port
tcp   LISTEN 0      128      0.0.0.0:22
tcp   LISTEN 0      511      0.0.0.0:80
```
Port 22 = SSH. Port 80 = Web server.

---

### Option 8: View Log File

**📂 Code location:** Lines 240–244  
**📌 Function name:** `view_log()`

```bash
tail -20 "$LOG_FILE"
```

- `tail` = Show the **last lines** of a file (like looking at the last page of a notebook).
- `-20` = Show the last 20 lines.

This shows you the most recent 20 actions recorded in `toolkit.log`.  
Every time any option is used, it was recorded there automatically by the `log()` function.

**Example output:**
```
2026-11-09 14:20:01 - Disk check run
2026-11-09 14:21:05 - Backup created: /home/tuser/sysadmin_toolkit/backups/backup_Documents.tar.gz
2026-11-09 14:22:30 - Health check run
2026-11-09 14:23:00 - User added: testuser
2026-11-09 14:25:00 - Toolkit closed
```

---

### Option 9: Exit

```bash
9) log "Toolkit closed"; echo "Goodbye!"; exit 0 ;;
```

- Writes `Toolkit closed` in the log file with the current time.
- Prints `Goodbye!` to the screen.
- `exit 0` = Quit the script. `0` means success (no errors).

---

### Part D — Auto Mode and Main Menu Loop

#### Auto Mode (Lines 247–253)

```bash
if [ "$1" == "--auto" ]; then
  disk_monitor > /dev/null
  health_check > /dev/null
  save_report  > /dev/null
  log "Auto mode finished"
  exit 0
fi
```

- `$1` = The first word typed after the script name when you run it.
- If you run `./toolkit.sh --auto`, then `$1 == "--auto"` is TRUE.
- The script then **skips the menu entirely**, runs disk check + health check + saves report quietly, and exits.
- `> /dev/null` = Throw away all screen output (run silently in background).
- This is designed to be used with **cron** so the computer runs these checks automatically every night.

#### The Main Menu Loop (Lines 255–285)

```bash
while true; do
  clear
  echo "1) Disk monitoring"
  ...
  read -rp "Choose an option [1-9]: " choice

  case $choice in
    1) disk_monitor ;;
    2) backup_menu ;;
    ...
    9) exit 0 ;;
    *) err "Invalid option" ;;
  esac
  pause
done
```

- `while true; do ... done` = **Infinite loop** — keeps repeating forever until you pick Option 9 to exit.
- `clear` = Clear the screen before showing the menu every time (looks clean and fresh).
- `read -rp "Choose [1-9]: " choice` = Wait for the user to type a number and store it in `choice`.
- `case $choice in` = Like a switch/selector — based on what number you typed, it calls the matching function.
- `*)` = The `*` is the "catch-all" — if you type anything that is not 1–9, it shows an error.
- `pause` = After each task finishes, it shows `Press Enter to continue...` and waits, so you can read the output before the menu reappears.

---

## 6. Automation with Cron

**What is cron?**  
`cron` is Linux's built-in alarm clock / task scheduler. You tell it "run this command every day at 2 AM" and it does it forever — even when you are sleeping!

**How to set it up:**
```bash
# Open the cron schedule editor
crontab -e
```

Add this line at the bottom:
```
0 2 * * * /bin/bash /mnt/f/Fall-2026/OS_Lab_Project/toolkit.sh --auto
```

**Reading the cron schedule (`0 2 * * *`):**

| Field | Your value | Meaning |
|---|---|---|
| Minute | `0` | At minute 0 |
| Hour | `2` | At 2:00 AM |
| Day of month | `*` | Every day |
| Month | `*` | Every month |
| Day of week | `*` | Every day of the week |

So: **Every day at 2:00 AM**, Linux will automatically run the toolkit silently, check the disk and system health, save a report to the `reports/` folder, and write to the log — all without you doing anything!

**Check it is set:**
```bash
crontab -l
```

---

## 7. Viva Quick-Answer Sheet

When your teacher asks you questions in the viva or lab presentation, use these short answers:

| Teacher's Question | Your Simple Answer |
|---|---|
| **What is `#!/bin/bash`?** | It is called the **shebang**. It tells Linux which program to use to run this script — in this case, the Bash shell. |
| **Why do we use `chmod +x`?** | Linux does not allow scripts to run just because they have `.sh` extension. We must manually give the **execute permission** using `chmod +x`. |
| **What is a variable in Bash?** | A variable is like a labelled box that stores a value. We write `NAME=value` to create it and `$NAME` to use it. |
| **What is a function in Bash?** | A function is a named block of reusable code. We define it once and call it by name whenever we need it, just like a shortcut. |
| **What does `df` show?** | `df` shows how much free and used space is on each disk partition (drive). |
| **What is the difference between `df` and `du`?** | `df` checks **total disk partition space**. `du` measures the **actual size of a specific folder and its files**. |
| **What is `/proc/loadavg`?** | It is a virtual file created by the Linux kernel that shows the average CPU load over 1, 5, and 15 minutes. |
| **What signal does `kill $pid` send?** | It sends **SIGTERM (Signal 15)** — a polite request for the process to close itself gracefully. |
| **What is `cron` used for?** | `cron` is a Linux task scheduler. It runs commands automatically at scheduled times without any human action. |
| **What does `>>` mean vs `>`?** | `>` **overwrites** a file (deletes old content and writes new). `>>` **appends** (adds to the end without deleting). |
| **Why is `/etc/passwd` used?** | It is Linux's user account database. Each line represents one user with their UID, group, home folder, and shell. |
| **What is `sudo`?** | `sudo` means "run as administrator". Only privileged commands like creating/deleting users need `sudo`. |
| **What is `--auto` flag for?** | It runs the script without the menu so it can be scheduled automatically with `cron` for unattended operation. |
| **What is `tail -20` for?** | `tail` reads the last N lines of a file. `tail -20` shows the last 20 lines of the log file. |
| **Why confirm before deleting?** | To prevent accidental deletion. The script always asks `(y/n)` before any irreversible action. |

---

> 🎉 **You have now read and understood the entire project!**  
> You can confidently explain every line of code, every menu option, and the automation feature.  
> Good luck with your OS Lab presentation! 🚀
