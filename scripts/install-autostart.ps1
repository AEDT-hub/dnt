# Einmalig ausführen (PowerShell): richtet den Autostart bei jeder Windows-Anmeldung ein.
$script = Join-Path $PSScriptRoot "start-onion.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::Zero)
Register-ScheduledTask -TaskName "OnionSeite" -Action $action -Trigger $trigger `
    -Settings $settings -Force | Out-Null
Write-Host "Autostart eingerichtet. Beim nächsten Login startet die Onion-Seite automatisch."
