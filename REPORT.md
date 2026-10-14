# Arvestustöö raport

Nimi: Markkus Toriland  
Variant: A  
Kuupäev: 13.10.2026  

Kontrollid tegin oma Debian 13 virtuaalmasinas `sv-markkus` kasutaja `user` alt.
Enne parandusi käivitasin `setup.sh` ning kõik skriptid erinevate sisenditega ja võrdlesin
tulemust Linuxi käskude (`hostname`, `whoami`, `uname -r`, `uptime -p`, `free -m`, `df -h`,
`getent passwd`, `systemctl is-active`, `file`, `tar -tzf`) väljundiga. Vajadusel kasutasin `bash -x`.

Kõik kontrollid on koondatud skripti `kontroll/kontroll.sh`; selle väljund enne parandusi on failis
`kontroll/enne.log` ja pärast parandusi failis `kontroll/parast.log`.

## Probleem 1
- Skript: `scripts/system_info.sh`
- Mida skript näiliselt tegi: kuvas süsteemi infot (hostname, kasutaja, kernel, uptime, mälu).
- Mis oli tegelikult vale: kõik väljad olid valed - "Hostname" näitas `whoami` väljundit ja "Kasutaja" `hostname` väljundit (vahetuses), "Kernel" näitas `uname -m` ehk arhitektuuri (`x86_64`), "Uptime" näitas hoopis praegust kellaaega (`date`) ja "Mälu kokku" võttis `free -m` väljundist Swap rea, mitte Mem rea.
- Kuidas vea avastasin: skript näitas "Hostname: user" ja "Kasutaja: sv-markkus", mis on ilmselgelt vahetuses; mälu oli 1721 MB, aga masinal on 1973 MB RAM-i.
- Millise käsuga kontrollisin: `hostname`, `whoami`, `uname -r`, `uptime -p`, `free -m`
- Parandus: `hostname` ja `whoami` õigetesse ridadesse, kernel `uname -r`, uptime `uptime -p`, mälu `free -m | awk '/^Mem:/ {print $2}'`.
- Kuidas kontrollisin pärast parandust: skripti väljund ühtib nende käskude väljundiga (nt "Hostname: sv-markkus", "Kasutaja: user", "Kernel: 6.12.74+deb13+1-amd64", "Uptime: up 1 hour, 40 minutes", "Mälu kokku: 1973 MB").

## Probleem 2
- Skript: `scripts/disk_check.sh`
- Mida skript näiliselt tegi: näitas kettakasutuse protsenti ja võrdles seda piiriga `DISK_LIMIT=80`.
- Mis oli tegelikult vale: `df -h /` väljundist võeti 4. veerg ehk **Avail** (vaba ruum, nt `27G`) ja `tr -dc '0-9'` eemaldas ühikud ja koma, nii et vaba ruumi gigabaitide arv kuvati protsendina. Nt `27G` -> "27%", aga `1.5T` -> "15%". Kontroll võrdles seega vaba ruumi kasutuse piiriga - täis ketta korral (vähe vaba ruumi) ütleks skript "OK".
- Kuidas vea avastasin: skript näitas "Kettakasutus: 27%", aga `df -h /` Use% veerg oli 5%. `bash -x scripts/disk_check.sh` näitas, et awk võtab väärtuse `$4`.
- Millise käsuga kontrollisin: `df -h /`, `bash -x scripts/disk_check.sh`
- Parandus: kasutusprotsent võetakse Use% veerust: `df --output=pcent / | tail -n 1 | tr -dc '0-9'`.
- Kuidas kontrollisin pärast parandust: skript näitab nüüd sama protsenti, mis `df -h /` (Use%).
- Exit code enne / pärast: 0 / 0 (ketas on alla 80% täis), aga nüüd põhineb see õigel arvul.

## Probleem 3
- Skript: `scripts/user_check.sh`
- Mida skript näiliselt tegi: kontrollis, kas kasutaja eksisteerib.
- Mis oli tegelikult vale: kontroll tehti failist `/etc/group` (gruppide fail, mitte kasutajakontod), `grep -c` otsis alamstringi ja tingimus `[ "$matches" -ge 0 ]` on alati tõene. Seega iga sisend, ka olematu kasutaja ja tühi string, "eksisteeris".
- Kuidas vea avastasin: `bash scripts/user_check.sh kasutaja_keda_ei_ole` ja `bash scripts/user_check.sh ""` väitsid mõlemad "eksisteerib" ja exit code oli 0.
- Millise käsuga kontrollisin: `getent passwd kasutaja_keda_ei_ole; echo $?` (tulemus 2 ehk ei ole), `echo $?` pärast skripti
- Parandus: tühja sisendi korral teade ja exit code 2; kasutaja olemasolu kontrollitakse `getent passwd "$username"` abil (täpne nimi kasutajate andmebaasist).
- Kuidas kontrollisin pärast parandust: `root` -> eksisteerib (exit 0), `kasutaja_keda_ei_ole` -> ei leitud (exit 1), `""` -> kasutajanimi puudu (exit 2).
- Exit code enne / pärast: olematu kasutaja 0 / 1, tühi sisend 0 / 2.

## Probleem 4
- Skript: `scripts/service_check.sh`
- Mida skript näiliselt tegi: kontrollis, kas teenus töötab.
- Mis oli tegelikult vale: kontrolliti ainult, kas `systemctl list-unit-files` nimekirjas on selle nimega unit-fail. Teenus, mis on paigaldatud aga seisatud, kuvati ikka "töötab". Olematu teenus ja peatatud teenus andsid sama teate ning tühja sisendi korral kuvati "Teenus  ei tööta." (tühi nimi).
- Kuidas vea avastasin: `bash scripts/service_check.sh systemd-networkd` ütles "Teenus systemd-networkd töötab.", aga `systemctl is-active systemd-networkd` andis `inactive`.
- Millise käsuga kontrollisin: `systemctl is-active systemd-networkd ssh`, `systemctl status systemd-networkd`
- Parandus: teenuse olekut kontrollitakse `systemctl is-active --quiet` abil. Kui teenus ei tööta, kontrollitakse unit-faili olemasolu, et eristada "olemas, aga ei tööta" (exit 1) ja "teenust ei ole" (exit 3); tühi sisend annab exit code 2.
- Kuidas kontrollisin pärast parandust: `ssh` -> töötab (0), `systemd-networkd` -> olemas, aga ei tööta (inactive) (1), `olematu` -> ei ole olemas (3), `""` -> nimi puudu (2).
- Exit code enne / pärast: `systemd-networkd` 0 / 1.

## Probleem 5
- Skript: `scripts/backup.sh`
- Mida skript näiliselt tegi: lõi varukoopia `backups/backup_KUUPAEV.tar.gz` ja teatas "Varukoopia valmis", failide arv 3.
- Mis oli tegelikult vale: `.tar.gz` fail oli tegelikult ainult `find` käsu väljund ehk tekstifail failinimedega. Failide sisu ei salvestatud ja arhiivi ei saa taastada. Kontroll `[ -s "$ARCHIVE" ]` vaatas ainult, et fail pole tühi.
- Kuidas vea avastasin: `file backups/backup_*.tar.gz` -> `ASCII text`; `tar -tzf backups/backup_*.tar.gz` -> `gzip: stdin: not in gzip format`.
- Millise käsuga kontrollisin: `file`, `tar -tzf`, `cat`
- Parandus: luuakse päris arhiiv `tar -czf "$ARCHIVE" -C "$BACKUP_SOURCE" .` ja kohe kontrollitakse seda `tar -tzf` abil; failide arv loetakse arhiivi sisust. Kui allikat pole, antakse viga. Lisasin ka logimise (`lib/common.sh` funktsioon `log_message` oli olemas, aga seda ei kasutatud kuskil).
- Kuidas kontrollisin pärast parandust: `file` -> `gzip compressed data`, `tar -tzf` näitab faile `./normal.txt`, `./important data.txt` (tühikuga nimi säilib) ja `./subdir/nested.txt`; arhiivi lahtipakkimisel ja `diff -r` võrdlusel algandmetega erinevusi ei olnud.
- Exit code enne / pärast: 0 / 0, aga nüüd ainult siis, kui arhiiv on tõesti korrektne.

## Probleem 6
- Skript: `main.sh`
- Mida skript näiliselt tegi: kuvas menüüd ja lõpetas valikuga 0.
- Mis oli tegelikult vale: kui sisend lõppeb (Ctrl+D või skript käivitatakse suunatud sisendiga), siis `read` ebaõnnestub, muutuja jääb tühjaks ja `while true` tsükkel trükib lõputult menüüd ja "Vale valik".
- Kuidas vea avastasin: `timeout 2 bash main.sh < /dev/null > /tmp/m.txt; echo $?` andis 124 (skript ei lõppenud ise) ja väljundis oli 275714 rida.
- Millise käsuga kontrollisin: `timeout`, `wc -l`, `echo $?`
- Parandus: `read -r -p "Valik: " c || exit 0` - sisendi lõppemisel programm lõpetab.
- Kuidas kontrollisin pärast parandust: sama käsk lõpetab kohe, exit code 0.
- Exit code enne / pärast: 124 (timeout katkestas) / 0.

## Uus funktsionaalsus
- Mida lisasin: varukoopia taastamise kontroll `scripts/restore_check.sh` (menüüs valik 6). Skript võtab kõige uuema varukoopia, pakib selle lahti ajutisse kataloogi ja võrdleb `diff -r` abil algandmetega. Tulemus (OK või erinevused) kirjutatakse ka logifaili `logs/toolkit.log`.
- Kuidas käivitada: `bash scripts/restore_check.sh` või `./main.sh` -> valik 6.
- Kuidas kontrollisin, et tulemus on õige: pärast `backup.sh` käivitamist andis kontroll "OK ... (3 faili)" ja exit code 0. Seejärel muutsin faili `testdata/source/important data.txt` sisu ja kontroll leidis erinevuse ning andis exit code 1. Katkise "arhiivi" (vana backup.sh väljund) korral annab skript vea, et arhiivi ei saa lahti pakkida.

## Muud tähelepanekud
- Projekti juurkataloogi lisasin `.gitignore` faili, et testandmed, logid ja loodud arhiivid ei satuks repositooriumisse.
