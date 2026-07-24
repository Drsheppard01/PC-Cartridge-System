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

    # Find compatdata directory first
    $COMPATDATA_DIR = Get-ChildItem -Path $ROOT -Directory -Recurse |
        Where-Object { $_.Name -eq "compatdata" } |
        Select-Object -First 1

    if (-not $COMPATDATA_DIR) {
        Write-Host "ERROR: No compatdata directory found"
        exit 1
    }

    Write-Host "Compatdata directory: $($COMPATDATA_DIR.FullName)"

    $COMPATDATA_PATH = $COMPATDATA_DIR.FullName
    # Search for all game folders inside compatdata
    $GAME_DIRS = Get-ChildItem `
        -Path $COMPATDATA_PATH `
        -Directory


    if ($GAME_DIRS.Count -eq 0) {
        Write-Host "ERROR: No game folders inside compatdata"
        exit 1
    }

    Write-Host "Found $($GAME_DIRS.Count) game(s) inside compatdata"


    # ------------------------------------------
    # Randomly pick one game folder
    # ------------------------------------------

    $INDEX = Get-Random -Minimum 0 -Maximum $GAME_DIRS.Count
    $GAMEID_DIR = $GAME_DIRS[$INDEX]

    # Removes the path, leaving only the game ID
    $GAME_ID = $GAMEID_DIR.Name

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