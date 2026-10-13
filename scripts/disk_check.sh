#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"

# Juurfailisüsteemi kasutusprotsent (df Use% veerg), nt "31%" -> 31
usage=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')

echo "Kettakasutus: ${usage}%"

if [ "$usage" -lt "$DISK_LIMIT" ]; then
    echo "OK: kettaruumi kasutus on normis."
    exit 0
else
    echo "HOIATUS: kettaruumi kasutus on liiga suur."
    exit 1
fi
