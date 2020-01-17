#!/bin/bash

FILES=$(find -regex '.*/.*\.\(c\|cpp\|yml\)$')
echo "Listing files in directory:"
echo "$FILES"

echo "Event path:"
echo "$GITHUB_EVENT_PATH"
