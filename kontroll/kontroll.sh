cd /home/user/sa-test
echo '## system_info'; bash scripts/system_info.sh; echo "hostname=$(hostname) whoami=$(whoami) uname-r=$(uname -r) uname-m=$(uname -m)"; uptime -p; free -m | head -3
echo '## disk_check'; bash scripts/disk_check.sh; echo "exit=$?"; df -h /
echo '## user_check'; for u in root kasutaja_keda_ei_ole ''; do bash scripts/user_check.sh "$u"; echo "exit=$?"; done
echo '## service_check'; for s in ssh systemd-networkd olematu ''; do bash scripts/service_check.sh "$s"; echo "exit=$?"; done; systemctl is-active ssh systemd-networkd olematu
echo '## backup'; bash scripts/backup.sh; echo "exit=$?"; f=$(ls -t backups/*.tar.gz | head -1); file "$f"; tar -tzf "$f"; echo "tar exit=$?"
echo '## main EOF'; timeout 2 bash main.sh < /dev/null > /tmp/m.txt; echo "exit=$?"; wc -l < /tmp/m.txt
