#!/bin/bash

# Check if a filename is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 filename.csv"
    exit 1
fi

# Check if the file exists
if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    exit 1
fi

# Function to convert a line of CSV to markdown
csv_to_md() {
    line="$1"
    IFS=',' read -r -a cols <<< "$line"
    printf "|"
    for col in "${cols[@]}"; do
        printf " %s |" "$col"
    done
    printf "\n"
}

# Read the header line and convert to markdown
read -r header < "$1"
csv_to_md "$header"

# Print the table separator line
IFS=',' read -r -a headers <<< "$header"
printf "|"
for header in "${headers[@]}"; do
    printf " --- |"
done
printf "\n"

# Print the rest of the lines
while IFS= read -r line; do
    csv_to_md "$line"
done < <(tail -n +2 "$1")
