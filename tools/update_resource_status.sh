#!/bin/bash

# Script to update the Resource Status table in README.md
# Changes ❌ to ✔ if the resource is present in resourceDefinition.json

# Calculate robust absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
README="$SCRIPT_DIR/../README.md"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"

# Extract all resource names from JSON
RESOURCES=$(jq -r '.[].name' "$RESDEF")

awk -v resources="$RESOURCES" '
  BEGIN {
    split(resources, arr, "\n");
    for (i in arr) present[arr[i]] = 1;
    in_table=0
  }
  /^\|resource \| status \|/ { in_table=1; print; next }
  in_table && /^\|/ {
    if ($0 ~ /⚠/) { print $0; next }
    split($0, a, "|")
    res=a[2]; gsub(/^ +| +$/, "", res)
    if (res == "resource" || res == "---") { print $0; next }
    status = (present[res]) ? "✔" : "❌"
    print "|" res " | " status " |"
    next
  }
  { print }
' "$README" > "$README.tmp" && mv "$README.tmp" "$README"

echo "Resource Status table updated in $README"