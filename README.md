# Onion-Seite einrichten

## Aufbau

```
onion-seite/
├─ docs/index.html            die Seite (GitHub Pages + Onion)
└─ scripts/
   ├─ start-onion.ps1         startet Webserver + Tor, trägt Onion-Adresse ein, pusht
   └─ install-autostart.ps1   richtet den Autostart bei Windows-Login ein
```

## Einmalige Einrichtung

1. **Tor Expert Bundle** von torproject.org laden (nicht den Tor Browser) und nach `C:\tor` entpacken,
   sodass `C:\tor\tor\tor.exe` existiert. Sonst den Pfad oben in `start-onion.ps1` anpassen.
2. **Python** installieren (für den lokalen Webserver) und **Git** einrichten, sodass `git push` ohne Passwort-Abfrage funktioniert (Git Credential Manager oder SSH-Key).
3. Diesen Ordner als **GitHub-Repo** hochladen.
   Unter *Settings → Pages* die Quelle auf **Branch main, Ordner /docs** stellen.
4. In PowerShell einmal ausführen: `scripts\install-autostart.ps1`
5. Einmal manuell testen: `scripts\start-onion.ps1`
   Nach ca. 1 Minute steht die `.onion`-Adresse in `docs/index.html` und ist auf GitHub gepusht.

## Wie die Weiterleitung funktioniert

GitHub Pages kann keine eigenen HTTP-Header senden. Der Tor Browser versteht `Onion-Location` aber auch als
`<meta http-equiv="onion-location">` im HTML. Genau das ist in `docs/index.html` eingebaut.
Öffnet jemand deine GitHub-Seite im Tor Browser, erscheint in der Adressleiste "Onion verfügbar".

## Wichtig

- Die Onion-Adresse bleibt gleich, solange der Ordner `C:\onion\hidden_service` bleibt. Das Script pusht deshalb nur, wenn sich die Adresse ändert (praktisch nur beim ersten Mal).
- `C:\onion\hidden_service\hs_ed25519_secret_key` ist dein privater Schlüssel. Nie ins Repo legen, nie weitergeben. Wer ihn hat, kann deine Adresse übernehmen. Sichere ihn an einem privaten Ort.
- Der Webserver liefert nur `docs/` aus und hört nur auf `127.0.0.1`. Das Repo selbst (inklusive `.git`) ist nicht erreichbar.
- Die Seite ist nur erreichbar, solange dein PC läuft und online ist.
- Log bei Problemen: `C:\onion\start.log`
