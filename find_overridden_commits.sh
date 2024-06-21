#!/bin/bash

commit_a=22954c3399bdea29a5291676d06246f8cfe8c150
commit_b=01daeaf336daf81342b34563e20bd9819a71f881

# Get the changes introduced by each commit
changes_a=$(git show "$commit_a" --pretty=format: --unified=0)
changes_b=$(git show "$commit_b" --pretty=format: --unified=0)

echo "Changes in A:"
echo "$changes_a"

echo "Changes in B:"
echo "$changes_b"

# Flags to track the conditions
overridden=false

# Check if any lines added in A are deleted in B
while IFS= read -r line; do
    if [[ "$line" =~ ^[+] ]]; then
        # Check if the added line from commit A is deleted in commit B
        if echo "$changes_b" | grep -q "^-${line:1}"; then
            overridden=true
            break
        fi
    fi
done <<< "$changes_a"

# Check if any lines deleted in A are added back in B
while IFS= read -r line; do
    if [[ "$line" =~ ^[-] ]]; then
        # Check if the deleted line from commit A is added back in commit B
        if echo "$changes_b" | grep -q "^+${line:1}"; then
            overridden=true
            break
        fi
    fi
done <<< "$changes_a"

# Output the result
if $overridden; then
    echo "Commit B overrides A."
else
    echo "Commit B does not override A."
fi
