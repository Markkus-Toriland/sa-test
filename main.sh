#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
while true; do
  echo; echo "1. Süsteemi info"; echo "2. Kettaruumi kontroll"; echo "3. Kasutaja kontroll"; echo "4. Teenuse kontroll"; echo "5. Varukoopia"; echo "0. Välju"
  read -r -p "Valik: " c || exit 0
  case "$c" in
    1) bash "$BASE_DIR/scripts/system_info.sh";;
    2) bash "$BASE_DIR/scripts/disk_check.sh";;
    3) read -r -p "Kasutaja: " u; bash "$BASE_DIR/scripts/user_check.sh" "$u";;
    4) read -r -p "Teenus: " s; bash "$BASE_DIR/scripts/service_check.sh" "$s";;
    5) bash "$BASE_DIR/scripts/backup.sh";;
    0) exit 0;;
    *) echo "Vale valik";;
  esac
done
