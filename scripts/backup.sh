#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"
source "$BASE_DIR/lib/common.sh"

DATE=$(date '+%Y%m%d_%H%M%S')
ARCHIVE="$BACKUP_DIR/backup_$DATE.tar.gz"

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "Varukoopia allikat $BACKUP_SOURCE ei ole (käivita enne setup.sh)."
    exit 1
fi

echo "Varukoopia loomine..."

# Loome päris tar.gz arhiivi; -C abil salvestatakse suhtelised teed, tühikud failinimedes säilivad
if tar -czf "$ARCHIVE" -C "$BACKUP_SOURCE" . && tar -tzf "$ARCHIVE" > /dev/null; then
    files=$(tar -tzf "$ARCHIVE" | grep -vc '/$')
    echo "Varukoopia valmis: $ARCHIVE"
    echo "Failide arv: $files"
    log_message "Varukoopia loodud: $ARCHIVE ($files faili)"
    exit 0
else
    echo "Varukoopia ebaõnnestus."
    rm -f "$ARCHIVE"
    log_message "Varukoopia ebaõnnestus"
    exit 1
fi
