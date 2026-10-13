#!/usr/bin/env bash
# Uus funktsionaalsus: kontrollib, kas viimane varukoopia on päriselt taastatav.
# Arhiiv pakitakse lahti ajutisse kataloogi ja võrreldakse diff -r abil algandmetega.

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"
source "$BASE_DIR/lib/common.sh"
mkdir -p "$(dirname "$LOG_FILE")"

latest=$(ls -1t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | head -n 1)
if [ -z "$latest" ]; then
    echo "Varukoopiaid ei leitud kataloogist $BACKUP_DIR."
    exit 1
fi

echo "Kontrollin varukoopiat: $latest"

tmp=$(mktemp -d)
if ! tar -xzf "$latest" -C "$tmp"; then
    echo "VIGA: arhiivi ei õnnestunud lahti pakkida."
    rm -rf "$tmp"
    log_message "Taastamise kontroll ebaõnnestus: $latest ei ole korrektne arhiiv"
    exit 1
fi

if diff -r "$BACKUP_SOURCE" "$tmp" > /dev/null; then
    echo "OK: varukoopia on taastatav ja ühtib algandmetega ($(find "$tmp" -type f | wc -l) faili)."
    log_message "Taastamise kontroll OK: $latest"
    rm -rf "$tmp"
    exit 0
else
    echo "HOIATUS: taastatud failid erinevad praegustest algandmetest:"
    diff -rq "$BACKUP_SOURCE" "$tmp"
    log_message "Taastamise kontroll: $latest erineb algandmetest"
    rm -rf "$tmp"
    exit 1
fi
