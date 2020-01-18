#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Branch name: $BRANCH"

FILES=$(find -regex '.*/.*\.\(c\|cpp\|yml\)$')
echo "Listing files in directory:"
echo "$FILES"

FILES=$(git ls-files -m)
echo "Modified files (git ls-files):"
echo "$FILES"

FILES=$(git diff --name-only --diff-filter=b $(git merge-base HEAD experimental))
echo "Modified files (git diff):"
echo "$FILES"

echo "Event path:"
echo "$GITHUB_EVENT_PATH"
