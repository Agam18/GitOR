#!/bin/bash

# Replace this with your target commit hash
TARGET_COMMIT=d6a3a46b5b761bdadbd96d5052ae4a062e11f60b

# Specify the file path that you want to analyze
FILE_PATH=1.txt

# Function to escape special characters for use in regex
escape_special_chars() {
    echo "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}

# Get the diff of the target commit and extract removed lines
git show $TARGET_COMMIT --unified=0 -- $FILE_PATH | grep -E '^---|^\+\+\+|^@@|^-'

# Parse the diff output
git show $TARGET_COMMIT --unified=0 -- $FILE_PATH | grep -E '^---|^\+\+\+|^@@|^-|^\+\+\+' | while read -r line; do
    if [[ $line =~ ^\-\-\- ]]; then
        continue  # Skip the old file path
    elif [[ $line =~ ^\+\+\+ ]]; then
        file=$(echo $line | sed 's/^+++ b\///')
    elif [[ $line =~ ^@@ ]]; then
        line_info=$(echo $line | sed 's/^@@ -\([0-9]*\).*/\1/')
    elif [[ $line =~ ^- ]]; then
        removed_line=$(echo $line | sed 's/^-//')

        # Escape special characters in the line for regex compatibility
        escaped_line=$(escape_special_chars "$removed_line")
        
        # Use git blame to find the commit that added this line
        original_commit=$(git blame -L "$line_info,+1" -- "$FILE_PATH" | grep -v '^00000000' | grep -v "$TARGET_COMMIT" | awk '{print $1}')

        if [ -z "$original_commit" ]; then
            echo "File: $FILE_PATH"
            echo "Line: $removed_line"
            echo "Original commit: Not found (may have been in the initial commit)"
            echo
        else
            echo "File: $FILE_PATH"
            echo "Line: $removed_line"
            echo "Original commit: $original_commit"
            echo
        fi
    fi
done
