# Student Attendance Tracker — Automated Setup Script

This project provides a **Bash automation script** that creates a complete Student Attendance Tracker workspace.

## The script:

- Dynamically generates the required directory structure.
- Creates all necessary source files.
- Supports optional configuration updates.
- Implements signal handling for safe interruption.
- Performs an environment validation check before completion.

---

## Requirements

- **Bash** (Linux environment)  
- **Python 3**  (to run attendance checker setup)  

---

## How to Run code
1. Clone repository:
```bash
git clone https://github.com/blewis-bump/deploy_agent_blewis-bump.git
cd deploy_agent_blewis-bump.git
```
2. Make the script executable:
```bash
chmod +x setup_project.sh
```
3. Run the script:
```bash
 ./setup_project.sh
```
4.Follow the prompts:                                                                                                       - **Enter a project identifier** — for example `v1`, `cohort2`. This creates a directory named `attendance_tracker_<your_input>/`
   - **Update thresholds (optional)** — if you choose `y`, you can enter new Warning and Failure percentages. The script uses `sed` to edit `config.json` in-place. Press Enter to keep defaults (Warning: 75%, Failure: 50%)

5. After setup, run the attendance checker:
   ```bash
   cd attendance_tracker_<your_input>
   python3 attendance_checker.py
   ```
# Generated Directory Structure

```
attendance_tracker_<input>/
├── attendance_checker.py       # Main Python application
├── Helpers/
│   ├── assets.csv              # Student attendance data
│   └── config.json             # Configurable thresholds
└── reports/
    └── reports.log             # Generated attendance reports
```

## How to Trigger the Archive Feature (Ctrl+C Trap)

The script implements a **signal trap** for `SIGINT` (Ctrl+C). If you interrupt the script at any point during execution:

1. The script catches the signal instead of terminating abruptly
2. It bundles the current state of the project directory into a compressed archive named `attendance_tracker_<input>_archive.tar.gz`
3. It deletes the incomplete project directory to keep your workspace clean

### Sample Test

```bash
$ ./setup_project.sh
Enter a project identifier (e.g., c1, cohort2) demo

===creating ridectory strature===
attendance_checker.py Created
assets.csv Created
config.json created
reports.log Created

Dynamic Configuration

Do you want to update attendance thresholds? (y/n) y

Current thresholds: Warning = 75%, Failure = 50%

Enter new Warning threshold (default 75): ^C
Script interrupted
bundling the current state of the parent directory into an archive .
Archive created: attendance_tracker_demo_archive.tar.gz
Incompleted directory 'attendance_tracker_demo' has been deleted.
```
### Extracting the Archive

To recover the archived project:
```bash
tar -xzf attendance_tracker_demo_archive.tar.gz
```
## Repository Contents

- **`setup_project.sh`** — Main Automation script
- **`README.md`** — Project Documentation
## Project video

[project video](https://drive.google.com/file/d/1sZP2HH5H3Jwz1JJwuRBAS_iSf99brJeX/view?usp=drive_link)
