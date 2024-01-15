#!/bin/bash

set -Eeuo pipefail

while true; do
    if ! ./wobble.py; then
        break
    fi
done
