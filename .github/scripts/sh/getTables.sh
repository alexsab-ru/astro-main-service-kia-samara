#!/bin/bash

# Simple sync of domain-specific tables from the astro-json repo
# We mirror the approach of downloadJSON.sh: read DOMAIN from env or .env
# and then copy the folder src/<DOMAIN>/data/tables from astro-json
# into this project's src/data/tables. We keep files in sync and delete removed ones.

Color_Off='\033[0m'
BGGREEN='\033[30;42m'
BGRED='\033[30;41m'

# Load DOMAIN from .env if not set
if [ -z "$DOMAIN" ] && [ -f .env ]; then
  export DOMAIN=$(grep '^DOMAIN=' .env | awk -F'=' '{print substr($0, index($0,$2))}' | sed 's/^"//; s/"$//')

if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN is not found"
  exit 1
fi

# Allow overriding astro-json repo path via JSON_REPO_PATH env or .env
if [ -z "$JSON_REPO_PATH" ] && [ -f .env ]; then
  export JSON_REPO_PATH=$(grep '^JSON_REPO_PATH=' .env | awk -F'=' '{print substr($0, index($0,$2))}' | sed 's/^"//; s/"$//')
fi

# Default to sibling repo ../astro-json if not provided
if [ -z "$JSON_REPO_PATH" ]; then
  JSON_REPO_PATH="../astro-json"
fi

SRC_DIR="$JSON_REPO_PATH/src/$DOMAIN/data/tables"
DST_DIR="src/data/tables"

echo "Using DOMAIN: $DOMAIN"
echo "Using JSON_REPO_PATH: $JSON_REPO_PATH"
echo "Source: $SRC_DIR"
echo "Destination: $DST_DIR"

if [ ! -d "$SRC_DIR" ]; then
  echo -e "${BGRED}Error: source directory not found: $SRC_DIR${Color_Off}"
  exit 1
fi

mkdir -p "$DST_DIR"

# Prefer rsync for efficient sync, fallback to cp -R
if command -v rsync >/dev/null 2>&1; then
  rsync -av --delete "$SRC_DIR/" "$DST_DIR/"
else
  # Remove destination first to mimic a clean sync
  rm -rf "$DST_DIR"/*
  cp -R "$SRC_DIR/" "$DST_DIR/"
fi

echo -e "${BGGREEN}Tables synced successfully${Color_Off}"
echo "Result files:"
ls -al "$DST_DIR" || true


