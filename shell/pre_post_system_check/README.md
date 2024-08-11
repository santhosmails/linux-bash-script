# 🐧 Linux Bash Script

**A comprehensive bash script for Linux that performs system checks and backups.**

---

## 📄 Overview

This script is designed to generate both a **precheck** and **postcheck** report of your machine. It collects crucial system information and saves it into a single file, making it easy to monitor your system's state before and after significant operations, such as a reboot. Additionally, it automatically backs up important files.

---

## 🛠️ Features

The script gathers and reports on the following system information:

- **🖥️ Host Information:** Detailed system and OS details.
- **🔍 Process Information:** Active processes and resource usage.
- **💽 Disk Information:** Disk space, partitions, and usage stats.
- **🌐 Network Information:** Network interfaces, IPs, and routing tables.
- **⚠️ Error Information:** Logs and error messages.
- **🔧 Hardware Information:** CPU, memory, and hardware component details.
- **🔄 Service Information:** Status of active and inactive services.
- **🧩 Miscellaneous Information:** Additional system metrics and statistics.
- **📂 Backup Information:** Files and configurations backed up by the script.
- **📋 Current System Processes:** A snapshot of running processes.

---

## 🚀 Getting Started

### 📥 Installation

Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/linux-bash-script.git
cd linux-bash-script
chmod 700 pre_postcheck.sh
./pre_postcheck.sh PRE
./pre_postcheck.sh POST
```
