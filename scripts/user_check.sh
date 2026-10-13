#!/usr/bin/env bash

username="$1"

# Tühja sisendi korral ei saa kontrolli teha
if [ -z "$username" ]; then
    echo "Kasutajanimi on puudu. Kasutamine: $0 kasutajanimi"
    exit 2
fi

# Kasutajakontod on kasutajate andmebaasis (/etc/passwd); getent otsib täpset nime, mitte alamstringi
if getent passwd "$username" > /dev/null; then
    echo "Kasutaja $username eksisteerib."
    exit 0
else
    echo "Kasutajat $username ei leitud."
    exit 1
fi
