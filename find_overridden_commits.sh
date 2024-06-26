#!/bin/bash

commit_a=1cd3ca89a7c1d4ec449733678d0be9890023d463
commit_b=ba2cff05356930fd46bffb66964b4eb4ace46fa9

# Get the changes introduced by each commit
changes_a=$(git show "$commit_a" --pretty=format: --unified=0)
changes_b=$(git show "$commit_b" --pretty=format: --unified=0)


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
