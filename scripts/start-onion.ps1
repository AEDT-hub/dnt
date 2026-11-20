# start-onion.ps1
# Startet beim Windows-Login: lokalen Webserver, Tor (Hidden Service),
# trägt die .onion-Adresse in docs/index.html ein und pusht sie zu GitHub.

# ===== ANPASSEN =====
$TorExe  = "C:\tor\tor\tor.exe"      # tor.exe aus dem "Tor Expert Bundle"
$DataDir = "C:\onion"                # Tor-Daten + geheimer Schlüssel (NICHT im Repo!)
$Port    = 8080                      # lokaler Port des Webservers
$Python  = "C:\Users\tomik\AppData\Local\Programs\Python\Python311\python.exe"
# ====================

$ErrorActionPreference = "Stop"
$Repo    = Split-Path $PSScriptRoot -Parent
$WebRoot = Join-Path $Repo "docs"
$HsDir   = Join-Path $DataDir "hidden_service"
$Torrc   = Join-Path $DataDir "torrc"
$Log     = Join-Path $DataDir "start.log"

New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
Start-Transcript -Path $Log -Force | Out-Null

# 1) torrc schreiben
@"
DataDirectory $DataDir\data
HiddenServiceDir $HsDir
HiddenServicePort 80 127.0.0.1:$Port
"@ | Set-Content -Path $Torrc -Encoding ASCII

# 2) Webserver nur auf localhost, nur der docs-Ordner (nie das ganze Repo!)
if (-not (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)) {
    Start-Process $Python -WindowStyle Hidden -ArgumentList @(
        "-m", "http.server", "$Port", "--bind", "127.0.0.1", "--directory", "`"$WebRoot`""
    )
}

# 3) Tor starten
if (-not (Get-Process tor -ErrorAction SilentlyContinue)) {
    Start-Process $TorExe -WindowStyle Hidden -ArgumentList @("-f", "`"$Torrc`"")
}

# 4) Auf die Onion-Adresse warten (bis zu 3 Minuten)
$HostFile = Join-Path $HsDir "hostname"
$waited = 0
while (-not (Test-Path $HostFile) -and $waited -lt 180) { Start-Sleep 2; $waited += 2 }
if (-not (Test-Path $HostFile)) { Write-Host "Keine Onion-Adresse gefunden."; Stop-Transcript; exit 1 }
$Onion = "http://" + (Get-Content $HostFile -Raw).Trim() + "/"
Write-Host "Onion-Adresse: $Onion"

# 5) Adresse in index.html eintragen (nur wenn sie sich geändert hat)
$IndexFile = Join-Path $WebRoot "index.html"
$html = Get-Content $IndexFile -Raw -Encoding UTF8
$new  = [regex]::Replace($html,
    '<meta http-equiv="onion-location" content="[^"]*">',
    "<meta http-equiv=`"onion-location`" content=`"$Onion`">")

if ($new -ne $html) {
    [IO.File]::WriteAllText($IndexFile, $new, (New-Object Text.UTF8Encoding $false))
    git -C $Repo add docs/index.html
    git -C $Repo commit -m "Onion-Adresse aktualisiert"
    git -C $Repo push
    Write-Host "GitHub aktualisiert."
} else {
    Write-Host "Adresse unverändert, nichts zu pushen."
}
Stop-Transcript | Out-Null
