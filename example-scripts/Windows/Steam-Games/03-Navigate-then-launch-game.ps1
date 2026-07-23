# Put this script on your SSD at root level and name it "launch.ps1".

#### This script will automatically detects the game on this storage device and navigate to the game's page on Steam then launch it. ####
# Meant for single game cartridges.

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


    # Take the folder name of the first folder inside compatdata as the game ID
    $GAMEID_DIR = Get-ChildItem -Path $COMPATDATA_DIR.FullName -Directory |
        Select-Object -First 1

    if (-not $GAMEID_DIR) {
        Write-Host "ERROR: No game folder inside compatdata"
        exit 1
    }

    Write-Host "Game folder: $($GAMEID_DIR.FullName)"


    # Removes the path, leaving only the game ID
    $GAME_ID = $GAMEID_DIR.Name

    Write-Host "Found Game ID: $GAME_ID"


    # ------------------------------------------
    # Navigate to game's page
    # ------------------------------------------

    Write-Host "Navigating to game's page on Steam..."

    Start-Process "steam://nav/games/details/$GAME_ID"
    Start-Process "steam://launch/$GAME_ID/dialog"
    # This might ask you to install the game if Steam doesn't detect the storage drive automatically. 
    # If that happens, just cancel the installation and go to Settings -> Storage -> Add Drive.

}
finally {
    Stop-Transcript
}