#!/bin/bash

set -e

PACKAGE_DIR="convention-portal"
ARCHIVE_NAME="convention-portal.tar.gz"

echo "Creating package directory..."
mkdir -p "$PACKAGE_DIR"

echo "Copying files (respecting .gitignore)..."
git ls-files | while read -r file; do
    # Create directory structure if needed
    dir=$(dirname "$file")
    if [ "$dir" != "." ]; then
        mkdir -p "$PACKAGE_DIR/$dir"
    fi
    # Copy file
    cp "$file" "$PACKAGE_DIR/$file"
done

echo "Creating tar.gz archive..."
tar -czf "$ARCHIVE_NAME" "$PACKAGE_DIR"

echo "Removing temporary directory..."
rm -rf "$PACKAGE_DIR"

echo "Package created: $ARCHIVE_NAME"
