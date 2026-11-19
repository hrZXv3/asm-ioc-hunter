# Résumé du projet

**ioc-hunter** est un petit outil de Cyber Threat Intelligence écrit en assembleur x86-64 (NASM, Linux). Il n'utilise pas la libc, seulement des appels système.

Il a deux modes :

1. **`scan`** lit un fichier de logs et affiche les lignes qui contiennent des traces d'attaque : Mimikatz, PowerShell encodé, suppression des sauvegardes par un ransomware, reverse shell, URL, site Tor.
2. **`xor`** décode la configuration cachée d'un faux malware, ce qui révèle l'adresse du serveur de l'attaquant.

Côté assembleur, le projet utilise la lecture des arguments sur la pile, les appels système `open`/`read`/`write`/`exit`, des boucles, une recherche de mot dans une ligne et l'opération XOR.

Un Makefile compile le projet, et 10 tests automatiques vérifient le bon fonctionnement et les cas d'erreur.
