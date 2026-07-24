# Put this script on your SSD at root level and name it "launch.ps1" (without quotes).

#### This script will automatically detects all the games on this storage device and randomly navigate to the game's page on Steam. ####
# Meant for cartridges with multiple games.

$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$LOG_FILE = Join-Path $ROOT "launch.log"

# Log all output to file
if (Test-Path $LOG_FILE) {
    Remove-Item $LOG_FILE
}
Start-Transcript -Path $LOG_FILE

try {

    # ------------------------------------------
    # Find Game ID
    # ------------------------------------------

    # Find steamapps directory first
    $STEAMAPPS_DIR = Get-ChildItem -Path $ROOT -Directory -Recurse |
        Where-Object { $_.Name -eq "steamapps" } |
        Select-Object -First 1

    if (-not $STEAMAPPS_DIR) {
        Write-Host "ERROR: No steamapps directory found"
        exit 1
    }

    Write-Host "Steamapps directory: $($STEAMAPPS_DIR.FullName)"

    # Search for all appmanifest files inside steamapps
    $GAMES = @(Get-ChildItem `
        -Path $STEAMAPPS_DIR.FullName `
        -Filter "appmanifest_*.acf" `
        -File)

    if ($GAMES.Count -eq 0) {
        Write-Host "ERROR: No appmanifest files inside steamapps"
        exit 1
    }

    Write-Host "Found $($GAMES.Count) game(s) inside steamapps"


    # ------------------------------------------
    # Randomly pick one game folder
    # ------------------------------------------

    # Randomly pick one game
    $GAME = Get-Random -InputObject $GAMES

    # Extract the Game ID from the filename
    if ($GAME.BaseName -match '^appmanifest_(\d+)$') {
        $GAME_ID = $Matches[1]
    }
    else {
        Write-Host "ERROR: Invalid appmanifest filename: $($GAME.Name)"
        exit 1
    }

    Write-Host "Selected Game ID: $GAME_ID"


    # ------------------------------------------
    # Navigate to game's page
    # ------------------------------------------

    Write-Host "Navigating to game's page on Steam..."

    Start-Process "steam://nav/games/details/$GAME_ID"

}
finally {
    Stop-Transcript
}