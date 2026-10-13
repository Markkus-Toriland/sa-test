#!/usr/bin/env bash

service="$1"

if [ -z "$service" ]; then
    echo "Teenuse nimi on puudu. Kasutamine: $0 teenus"
    exit 2
fi

# Kontrollime teenuse tegelikku olekut, mitte ainult unit-faili olemasolu
if systemctl is-active --quiet "$service" 2>/dev/null; then
    echo "Teenus $service töötab."
    exit 0
elif systemctl list-unit-files --type=service --all 2>/dev/null | awk '{print $1}' | grep -qx "${service}.service"; then
    echo "Teenus $service on olemas, aga ei tööta ($(systemctl is-active "$service" 2>/dev/null))."
    exit 1
else
    echo "Teenust $service ei ole olemas."
    exit 3
fi
