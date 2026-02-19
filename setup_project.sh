#!/usr/bin/env bash

# Global project directory(used by trap handler)

parent_dir=""
handle_interrupt(){
	echo " "
	echo "script interrupted"
       echo " compressing the current state of the parent directory into an archive"
if [[ -d "$parent_dir" ]]; then
	archive_dir="${parent_dir}_archive_$(date +%y%m%d_%H%M%S)"
tar -czf "${archive_dir}.tar.gz" "$parent_dir" 2>/dev/null
echo " archive created: ${archive_dir}.tar.gz"
rm -rf "$parent_dir"
echo "Incompleted directory '${parent_dir}' has been deleted"
else
	echo " No directory to archive"
fi
exit 1
}
trap handle_interrupt SIGINT

#prompts a user to enter a name for folder
read -p "enter the class identifier:(eg:c1,c2,Cn) " user_input
if [[ -z "$user_input" ]]; then
	echo " no input provided"
       exit 1
fi
parent_dir="attendance_tracker_${user_input}"
if [[ -d "$parent_dir" ]]; then
	echo "error:directory '${parent_dir}'already exists."
	exit 1
fi
mkdir -p "$parent_dir/Helpers"
mkdir -p "$parent_dir/reports"

cat<<EOF > "$parent_dir/attendance_checker.py" 
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
#Creating asset file inside Helpers folder
cat <<EOF > "$parent_dir/Helpers/assets.csv" 
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
#creating config.json file inside Helpers folder 
cat <<EOF > "$parent_dir/Helpers/config.json" 
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
#creating reports.log file inside report folder 
cat <<EOF > "$parent_dir/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo " " 
tree -F 

# Dynamic configuration (stream editing)
read -p "do you want to modify attendance threshold?: (Yes/no): " modify_choice
if [[ "$modify_choice" == "yes" ]]; then
       echo " "
echo " current thresholds: warning = 75%,failure = 50%"
read -p " enter new warning threshold(%):" new_warning
read -p " enter new failure threshold(%):" new_failure
sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" "$parent_dir/Helpers/config.json"
sed -i "s/\"failure\": [0-9]*/\"failure\": $new_failure/" "$parent_dir/Helpers/config.json"
echo " "

else
echo " Default threshold retained (warning = 75%,failure = 50%)"
fi

#Environment healthcheck

echo " running system healthcheck."
echo " "

if python3 --version; then
	python_version=$(python3 --version 2>&1)
	echo " python detected.${python_version}"
else
	echo " warning: python3 is not installed on this system."
fi
struct_valid=true
#checking environment structure.

if [[ ! -d "$parent_dir" ]]; then
	echo " error:parent directory missing"
	struct_valid=false
fi

if [[ ! -f "$parent_dir/attendance_checker.py" ]]; then
	echo " error: attendance_checker.py file missing"
	struct_valid=false
fi

if [[ ! -d "$parent_dir/Helpers" ]]; then
        echo " error: Helpers directory missing"
        struct_valid=false
fi

if [[ ! -f "$parent_dir/Helpers/assets.csv" ]]; then
        echo " error: assets.csv file missing"
        struct_valid=false
fi

if [[ ! -f "$parent_dir/Helpers/config.json" ]]; then
        echo " error: config.json file missing"
        struct_valid=false
fi

if [[ ! -d "$parent_dir/reports" ]]; then
        echo " error: reports directory missing"
        struct_valid=false
fi

if [[ ! -f "$parent_dir/reports/reports.log" ]]; then
        echo " error: reports.log file missing"
	struct_valid=false
fi

if [[ "$struct_valid" = true ]]; then
	echo " file structure maintained"
else
	echo " there are missing files or directories"
fi
