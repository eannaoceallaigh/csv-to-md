#!/bin/bash

# Check if a filename, sprint value and slack token are provided
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 filename.csv sprint_value slack_token"
    exit 1
fi

# Check if the file exists
if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    exit 1
fi

filename=$1
sprint_value=$2
slack_token=$3

# Find the index of the Sprint and Name columns
header=$(head -n 1 "$filename")
IFS=',' read -r -a columns <<< "$header"
for index in "${!columns[@]}"; do
    if [[ "${columns[index]}" = "sprint" ]]; then
        sprint_index=$index
    fi
    if [[ "${columns[index]}" = "Name" ]]; then
        name_index=$index
    fi
done

# Check if the Sprint and Name columns were found
if [[ -z "$sprint_index" ]]; then
    echo "Sprint column not found in $filename"
    exit 1
fi
if [[ -z "$name_index" ]]; then
    echo "Name column not found in $filename"
    exit 1
fi

# Send a Slack message to each person that matches the sprint value
while IFS=',' read -r -a line; do
    if [[ "${line[sprint_index]}" = "$sprint_value" ]]; then
        name="${line[name_index]}"
        message="Hello $name, you have tasks in sprint $sprint_value"
        curl -X POST -H 'Content-type: application/json' -H "Authorization: Bearer $slack_token" \
            --data "{\"channel\":\"@$name\",\"text\":\"$message\"}" \
            https://slack.com/api/chat.postMessage
    fi
done < <(tail -n +2 "$filename")
