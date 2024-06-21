#!/bin/bash

# Replace this with your target commit hash
TARGET_COMMIT=ba2cff05356930fd46bffb66964b4eb4ace46fa9

# Get the diff of the target commit
git show $TARGET_COMMIT | grep '^-' | sed 's/^-//' | while read -r line; do
    # Use git blame to find the commit that added this line
    original_commit=$(git blame -L "/$line/" --reverse $(git rev-list --all -- path/to/file) -- | head -n 1 | awk '{print $1}')
    
    echo "Line: $line"
    echo "Original commit: $original_commit"
    echo
done
