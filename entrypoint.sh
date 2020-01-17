#!/bin/bash

FILES = `ls -l`
echo "Listing files in directory:"
echo "$FILES"

echo "Event path:"
echo "$GITHUB_EVENT_PATH""
