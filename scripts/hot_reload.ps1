$path = Get-Location

Write-Host "Watching Flutter project for changes..."

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $path
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.dart"
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher Changed -Action {
    Write-Host "Change detected. Restarting Flutter..."
    Get-Process dart -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Process "flutter" "run"
}

while ($true) {
    Start-Sleep 1
}