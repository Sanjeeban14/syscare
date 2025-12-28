# syscare 🛠️

**syscare** is a Bash-based Linux system maintenance and health automation tool built with a terminal-first mindset.

It helps you monitor system health, safely clean old files, and perform automated backups with rotation — all using standard Linux utilities and clean Bash practices.

---

## ✨ Features

### 🔍 System Health Checks
- CPU load (1-minute average)
- Memory usage with warning thresholds
- Disk usage per mount point
- Colored terminal output
- Logged results for later inspection

### 🧹 Safe Cleanup
- Scans logs and reports for old files
- Dry-run mode enabled by default
- Explicit `--apply` flag required for deletion
- Configurable age threshold (`--days=N`)

### 💾 Automated Backups
- Creates timestamped `.tar.gz` archives
- Excludes backup directory to prevent recursion
- Automatic backup rotation (keeps last N backups)
- Uses safe `tar` directory handling

### 🧠 System-Oriented Design
- Modular Bash architecture
- Centralized logging
- Absolute path resolution
- Defensive scripting (`set -euo pipefail`)
- No GUI, no web UI — terminal only

---

## 📁 Project Structure

```text
syscare/
├── syscare.sh          # Main CLI entry point
├── lib/
│   ├── utils.sh        # Logging, colors, safety helpers
│   ├── health.sh       # System health checks
│   ├── cleanup.sh      # Cleanup logic (dry-run by default)
│   └── backup.sh       # Backup and rotation logic
├── config/
├── backups/
├── reports/
├── logs/
├── README.md
└── .gitignore

⚙️ Requirements
Ubuntu Linux (or any GNU/Linux system)
Bash
Standard GNU utilities:
tar
df
free
uptime
find

No external dependencies required.

🚀 Usage
Make the script executable (once):

```bash
chmod +x syscare.sh
```

Run individual modules
```bash
./syscare.sh check        # Run system health checks
./syscare.sh cleanup      # Scan old files (dry-run)
./syscare.sh backup       # Create backup + rotate old backups
```
Apply cleanup (actual deletion)
```bash
./syscare.sh cleanup --apply
```
Customize cleanup age
```bash
./syscare.sh cleanup --days=10 --apply
```
Run everything at once
```bash
./syscare.sh all
```
This runs:

Health checks

Cleanup

Backup + rotation

📝 Logging
All operations are logged to:

text
logs/syscare.log
Logs include timestamps and severity levels:

INFO

WARN

ERROR

🔐 Safety Notes
Cleanup runs in dry-run mode by default

Deletions require explicit --apply

Backup directory is excluded to prevent self-inclusion

Scripts exit immediately on errors

This tool is designed to be safe by default.

🎯 Learning Goals of This Project
This project was created to practice:

Linux system inspection

Bash scripting beyond basics

Modular script architecture

Defensive programming

Git and GitHub (CLI-based workflow)

Reading and interpreting system state

📌 Project Status
✅ Completed
🧪 Tested locally
🔧 Open for future enhancements (cron support, config files, email reports)