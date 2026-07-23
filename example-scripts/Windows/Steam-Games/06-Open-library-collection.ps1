# Put this script on your SSD at root level and name it "launch.ps1"
#
# Automatically detects all games on this storage device and searches
# Steam user collections to find the Collection ID containing the most games.
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
# Find Game IDs
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

    # Search for all game folders inside compatdata
    $GAME_DIRS = Get-ChildItem `
        -Path $COMPATDATA_PATH `
        -Directory

    if ($GAME_DIRS.Count -eq 0) {
        Write-Host "ERROR: No game folders inside compatdata"
        exit 1
    }


    $GAME_IDS = @()

    foreach ($GAME_DIR in $GAME_DIRS) {
        $GAME_ID = $GAME_DIR.Name
        $GAME_IDS += $GAME_ID
        Write-Host "Found game: $GAME_ID"
    }


# ------------------------------------------
# Find Steam root directory
# ------------------------------------------

    $STEAM_ROOT = $null

    # First try registry
    try {
        $STEAM_ROOT = (Get-ItemProperty `
            "HKCU:\Software\Valve\Steam" `
            -ErrorAction Stop).SteamPath
    }
    catch {
    }

    # Normalize slashes
    if ($STEAM_ROOT) {
        $STEAM_ROOT = $STEAM_ROOT.Replace("/", "\")
    }

    # Fallback locations
    if (-not $STEAM_ROOT) {
        $STEAM_LOCATIONS = @(
            "${env:ProgramFiles(x86)}\Steam"
            "${env:ProgramFiles}\Steam"
        )

        foreach ($path in $STEAM_LOCATIONS) {
            if (Test-Path "$path\userdata") {
                $STEAM_ROOT = $path
                break
            }
        }
    }


    if (-not $STEAM_ROOT) {
        Write-Host "Steam installation folder not found"
        exit 1
    }

    Write-Host "Steam root found: $STEAM_ROOT"


# ------------------------------------------
# Find Steam user collections
# ------------------------------------------

    $STEAM_USERDATA = Join-Path $STEAM_ROOT "userdata"

    $COLLECTION_FILES = Get-ChildItem `
        -Path $STEAM_USERDATA `
        -Recurse `
        -File `
        -Filter "*" |
        Where-Object {
            $_.FullName -like "*config\cloudstorage\*"
        }

    if ($COLLECTION_FILES.Count -eq 0) {
        Write-Host "No Steam cloudstorage files found."
        exit 1
    }

    Write-Host "Searching Steam collections..."

    $COLLECTION_IDS = @()
    $COLLECTION_NAMES = @()
    $COLLECTION_GAMES = @()

    foreach ($FILE in $COLLECTION_FILES) {

        $CONTENT = Get-Content `
            $FILE.FullName `
            -Raw `
            -Encoding UTF8

        $MATCHES = [regex]::Matches(
            $CONTENT,
            'user-collections\.uc-[A-Za-z0-9]+'
        )

        $KEYS = $MATCHES |
            ForEach-Object {
                $_.Value
            } |
            Sort-Object -Unique

        foreach ($KEY in $KEYS) {

            $COLLECTION_ID = $KEY.Replace(
                "user-collections.",
                ""
            )

            $PATTERN = 
            '"key":"user-collections\.' +
            [regex]::Escape($COLLECTION_ID) +
            '"[^}]*}'

            $DATA_MATCH = [regex]::Match(
                $CONTENT,
                $PATTERN
            )

            if (-not $DATA_MATCH.Success) {
                continue
            }

            $DATA = $DATA_MATCH.Value

            if ($DATA -match '"is_deleted":true') {
                continue
            }

            $NAME = ""

            if ($DATA -match '"name":"([^"]*)"') {
                $NAME = $matches[1]
            }

            $GAMES = ""

            if ($DATA -match '"added":\[([^\]]*)\]') {
                $GAMES = $matches[1]
            }

            Write-Host "--------------------------------"
            Write-Host "Collection ID: $COLLECTION_ID"
            Write-Host "Name: $NAME"
            Write-Host "Games: $GAMES"

            $COLLECTION_IDS += $COLLECTION_ID
            $COLLECTION_NAMES += $NAME
            $COLLECTION_GAMES += $GAMES
        }
    }


# ------------------------------------------
# Find best matching collection
# ------------------------------------------

    $BEST_INDEX = -1
    $BEST_SCORE = -1

    for ($i = 0; $i -lt $COLLECTION_IDS.Count; $i++) {

        $SCORE = 0
        $GAMES = $COLLECTION_GAMES[$i] -split ","

        foreach ($CART_GAME in $GAME_IDS) {
            foreach ($COLLECTION_GAME in $GAMES) {
                if ($CART_GAME -eq $COLLECTION_GAME.Trim()) {
                    $SCORE++
                    break
                }
            }
        }

        Write-Host ""
        Write-Host "Collection: $($COLLECTION_NAMES[$i])"
        Write-Host "Score: $SCORE"

        if ($SCORE -gt $BEST_SCORE) {
            $BEST_SCORE = $SCORE
            $BEST_INDEX = $i
        }
    }



    if ($BEST_INDEX -ge 0) {
        Write-Host ""
        Write-Host "Most likely Collection: $($COLLECTION_NAMES[$BEST_INDEX])"
        Write-Host "Collection ID: $($COLLECTION_IDS[$BEST_INDEX])"
        Write-Host "Matching games: $BEST_SCORE"
    }

    else {
        Write-Host "No matching collection found."
        exit 1
    }



# ------------------------------------------
# Open Steam collection
# ------------------------------------------


    $COLLECTION_ID = $COLLECTION_IDS[$BEST_INDEX]


    Write-Host "Navigating to Steam collection..."

    Start-Process "steam://nav/games/library/collection/$COLLECTION_ID"

}

finally {

    Stop-Transcript

}