# OS LAB PROJECT VIVA PREPARATION GUIDE
## Project: Automated SysAdmin Toolkit (`toolkit.sh`)

This guide contains the most common questions asked by professors and lab evaluators for an Operating Systems shell scripting project, along with exact technical answers based on your source code.

---

### Category 1: Shell Scripting Fundamentals

#### Q1: What does `#!/bin/bash` on line 1 do? What happens if it is omitted?
**Answer:**  
It is called the **shebang** (or hashbang). It tells the operating system's program loader which interpreter to execute the script with (in this case, `/bin/bash`). If omitted, the script executes using the user's current shell (e.g., `sh`, `zsh`, `dash`), which might not support bash-specific features like `[[ ... ]]` or arrays.

#### Q2: What is the purpose of `chmod +x toolkit.sh`?
**Answer:**  
In Linux, files do not gain execution rights from file extensions (`.sh`). `chmod +x` adds the execution bit (`+x`) to the file permissions in the inode. Without this permission, running `./toolkit.sh` returns a `Permission denied` error.

#### Q3: Why do you quote variables like `"$BACKUP_DIR"` or `"$src"`?
**Answer:**  
Quoting prevents **word splitting** and **pathname expansion (globbing)**. If a folder path contains spaces (e.g., `/home/user/My Documents`), unquoted variables treat each word as separate arguments, breaking commands like `mkdir`, `tar`, and `cd`.

#### Q4: How does the script handle both interactive menu mode and automated mode?
**Answer:**  
By inspecting the first positional parameter `$1`.  
At line 247, `if [ "$1" == "--auto" ]; then` checks if the user provided `--auto`. If so, it invokes the background functions (`disk_monitor`, `health_check`, `save_report`), redirects stdout to `/dev/null`, and terminates with `exit 0`, bypassing the interactive `while` menu.

---

### Category 2: Operating System Internals & Linux Kernel

#### Q5: How does the script calculate CPU load without third-party monitoring tools?
**Answer:**  
It reads `/proc/loadavg` via `cut -d' ' -f1 /proc/loadavg`. The `/proc` directory is a virtual pseudo-filesystem generated dynamically by the Linux kernel. The first field represents the average number of processes in the runnable and uninterruptible states over the last 1 minute. The script compares this value against the core count retrieved from `nproc`.

#### Q6: How does the script calculate percentage memory usage in `health_check()`?
**Answer:**  
It reads the output of `free` and parses it using `awk`:
```bash
free | awk '/Mem:/ {printf "%.0f", $3/$2*100}'
```
`$3` represents the used memory and `$2` represents total memory. Dividing `$3` by `$2` and multiplying by 100 calculates the exact percentage of used RAM.

#### Q7: Where are user accounts stored, and how does `user_menu()` list normal users?
**Answer:**  
User accounts are registered in `/etc/passwd`. Each record is colon-separated: `username:password:UID:GID:...`. In modern Linux distributions, regular (non-system) human users have UIDs starting at 1000 up to 65534. The script uses:
```bash
awk -F: '$3>=1000 && $3<65534 {print " - "$1}' /etc/passwd
```
This filters out system daemon accounts (like `daemon`, `bin`, `sys`, `nobody`).

---

### Category 3: Process Management & Signals

#### Q8: What Linux signal does `kill "$pid"` send by default?
**Answer:**  
By default, the `kill` command transmits **`SIGTERM` (Signal 15)**. `SIGTERM` requests graceful process termination, allowing the program to flush file buffers, release locks, and close open sockets. If a process hangs, a forceful termination can be executed using `kill -9` (**`SIGKILL`**).

#### Q9: What safety validations are applied before killing a process in `process_menu()`?
**Answer:**  
Two safety validations are executed:
1. **Format Validation:** `[[ "$pid" =~ ^[0-9]+$ ]]` ensures the input is strictly numeric to avoid invalid arguments.
2. **Existence Validation:** `ps -p "$pid" > /dev/null` verifies that a process with that PID is actively running before confirmation is requested.

---

### Category 4: Storage, Archiving & Network

#### Q10: What is the difference between `df` and `du` used in Option 1?
**Answer:**  
- **`df` (Disk Free):** Queries the filesystem superblocks to report total, used, and available space on mounted filesystems.
- **`du` (Disk Usage):** Recursively traverses the directory tree to compute the cumulative storage consumed by specific directories and files.

#### Q11: In `tar -czf "$file" -C "$(dirname "$src")" "$(basename "$src")"`, what do the flags mean?
**Answer:**  
- `-c`: Create a new archive.
- `-z`: Compress the archive using `gzip`.
- `-f`: Specify the filename of the archive.
- `-C <directory>`: Change to the specified directory before archiving. This avoids storing absolute system paths inside the archive and ensures clean extraction.

#### Q12: How does the backup cleanup routine identify and remove old archives?
**Answer:**  
It uses the `find` utility with the modification time flag:
```bash
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$KEEP_DAYS" -delete
```
`-mtime +7` filters files modified more than 7 days ago.

#### Q13: What is the advantage of using `ss -tuln` over legacy `netstat`?
**Answer:**  
`netstat` is deprecated because it parses socket information slowly via `/proc/net`. `ss` (Socket Statistics) communicates directly with kernel netlink subsystem, providing faster inspection of TCP (`-t`), UDP (`-u`), listening (`-l`), and numerical addresses (`-n`).

---

### Category 5: Security & Cron Automation

#### Q14: How does the script prevent an administrator from locking or deleting their own active session?
**Answer:**  
Before executing `userdel -r "$u"`, the script checks:
```bash
if [ "$u" == "$USER" ]; then err "You cannot delete yourself"; return; fi
```
`$USER` is an environment variable holding the currently authenticated shell username.

#### Q15: Explain the structure of the crontab expression `0 2 * * *`.
**Answer:**  
Crontab has 5 scheduling fields:
- `0`: Minute (0th minute of the hour)
- `2`: Hour (2:00 AM)
- `*`: Day of month (every day)
- `*`: Month (every month)
- `*`: Day of week (every day from Sunday to Saturday)  
Therefore, `0 2 * * *` triggers the command every day at exactly 2:00 AM.

