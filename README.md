# Skriptimise alused arvestustöö – Linuxi skriptide kontrollimine ja parandamine

Skriptid võivad käivituda ja kuvada usutava tulemuse, kuid sinu ülesandeks veenduda et kõik mis nad teevad on õige.

## Töö etapid

1. Klooni repositoorium.
2. Käivita `setup.sh`.
3. Uuri projekti failistruktuuri ja skripte.
4. Käivita skripte erinevate sisenditega.
5. Leia vähemalt **6 sisulist probleemi**.
6. Kirjelda probleemid failis `REPORT.md`.
7. Paranda leitud vead.
8. Kontrolli pärast iga parandust, et skript annab nüüd õige tulemuse.
9. Lisa üks uus funktsionaalsus.
10. Tee suuremad parandused eraldi Git commit'idena.
11. Lükka valmis töö oma GitHubi repositooriumisse.

## Kuidas skripte kontrollida?

Sa ei pea kirjutama automaatteste.

Kasuta kontrollimiseks Linuxi käske ja skripti enda käivitamist. Vajadusel kasuta silumisrežiimi:

```bash
bash -x scripts/disk_check.sh
```

Kontrolli vajadusel lõpetamise staatust:

```bash
echo $?
```

Proovi erinevaid sisendeid:

```bash
bash scripts/user_check.sh root
bash scripts/user_check.sh kasutaja_keda_ei_ole
bash scripts/user_check.sh ""
```

Varukoopia puhul ära usalda ainult faili nime või teadet:

```bash
file backups/backup.tar.gz
tar -tzf backups/backup.tar.gz
```

## Mida tuleb kindlasti kontrollida?

- kas skript mõõdab tegelikult õiget asja;
- korrektne ja tühi sisend;
- olemasolev ja olematu kasutaja;
- töötav ja mittetöötav/olematu teenus;
- kas varukoopiafail on päriselt taastatav arhiiv;
- kas tühikuga failinimi säilib;
- kas exit code on vajadusel õige.

## Git nõuded

Vähemalt 4 sisulist paranduse commit'i, 1 uue funktsionaalsuse commit ja dokumentatsiooni täiendamise commit.

## Esitamine

Esita GitHubi repositooriumi link.

## Tehtud töö (Markkus Toriland)

Leitud vead, nende kontrollimise käsud ja parandused on kirjas failis [REPORT.md](REPORT.md).
Parandatud skriptid: `system_info.sh`, `disk_check.sh`, `user_check.sh`, `service_check.sh`, `backup.sh` ja `main.sh`.

### Uus funktsionaalsus: varukoopia taastamise kontroll

`scripts/restore_check.sh` (menüüs valik **6**) pakib kõige uuema varukoopia ajutisse kataloogi lahti
ja võrdleb seda `diff -r` abil algandmetega. Nii on näha, kas varukoopia on päriselt taastatav.

```bash
bash setup.sh
bash scripts/backup.sh
bash scripts/restore_check.sh
echo $?    # 0 = varukoopia on korras, 1 = viga või erinevus
```
