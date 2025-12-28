# syscare

A Bash-based Linux system maintaiance and health automation tool.

## Features
 - System health checks (CPU, memory, disk)
 - Safe cleanup of logs and caches
 - Automated backups with rotation
 - Human readable reports

## Requirements
 - Ubuntu Linux
 - Bash
 - Standard GNU utilities

## Usage

Run individual modules:

```bash
./syscare.sh check       # System health
./syscare.sh cleanup     # Clean old logs/reports (dry-run by default)
./syscare.sh cleanup --apply  # Actually delete
./syscare.sh backup      # Backup project directory
./syscare.sh all         # Run all modules sequentially
```
Configure retention and days via optional flags:
```bash
./syscare.sh cleanup --days=10 --apply
```