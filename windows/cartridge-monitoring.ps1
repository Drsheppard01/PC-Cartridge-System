# PC Cartridge System Monitor
# Watches for inserted drives and launches trusted launch.ps1 cartridges.

$InstallFolder = Join-Path $env:LOCALAPPDATA "PC-Cartridge-System"

$LogFile = Join-Path $InstallFolder "monitor.log"
$TrustFile = Join-Path $InstallFolder "trusted_scripts.sha256"

$ConfigFile = Join-Path $InstallFolder "settings.conf"

$DebounceSeconds = 5


if (-not (Test-Path $InstallFolder)) {
    New-Item -ItemType Directory -Path $InstallFolder -Force | Out-Null
}

if (-not (Test-Path $TrustFile)) {
    New-Item -ItemType File -Path $TrustFile -Force | Out-Null
}

if (-not (Test-Path $ConfigFile)) {
    "MODE=running" | Out-File $ConfigFile -Encoding UTF8
}


$LastLaunches = @{}


function Write-Log {
    param(
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content `
        -Path $LogFile `
        -Value "[$timestamp] $Message"
}


function Get-FileHashSHA256 {
    param(
        [string]$Path
    )

    return (Get-FileHash `
        -Path $Path `
        -Algorithm SHA256).Hash.ToLower()
}


function Is-TrustedScript {
    param(
        [string]$Hash
    )

    if (-not (Test-Path $TrustFile)) {
        return $false
    }

    $TrustedHashes = Get-Content $TrustFile

    return $TrustedHashes -contains $Hash
}

function Get-Mode {

    if (-not (Test-Path $ConfigFile)) {
        return "stopped"
    }


    $ModeLine = Get-Content $ConfigFile |
        Where-Object { $_ -like "MODE=*" }


    if ($ModeLine) {

        $Mode = $ModeLine.Split("=")[1]

        return $Mode.ToLower()

    }


    return "stopped"
}


Write-Log "PC Cartridge System monitor started."


$null = Register-WmiEvent `
    -Class Win32_VolumeChangeEvent `
    -SourceIdentifier "PCCartridgeSystem" `
    -Action {


        $eventType = $Event.SourceEventArgs.NewEvent.EventType


        # 2 = drive inserted
        if ($eventType -ne 2) {
            return
        }


        $drive = $Event.SourceEventArgs.NewEvent.DriveName


        if ([string]::IsNullOrWhiteSpace($drive)) {
            return
        }


        $launcher = Join-Path $drive "launch.ps1"


        if (-not (Test-Path $launcher)) {
            return
        }


        # Debounce
        $now = Get-Date


        if ($LastLaunches.ContainsKey($drive)) {

            $elapsed = ($now - $LastLaunches[$drive]).TotalSeconds

            if ($elapsed -lt $DebounceSeconds) {

                Write-Log "Ignoring duplicate event for $drive"

                return
            }
        }


        $LastLaunches[$drive] = $now


        Write-Log "Cartridge detected: $drive"

        $Mode = Get-Mode


        if ($Mode -ne "running") {

            Write-Log "Cartridge execution disabled. Current mode: $Mode"

            return
        }


        try {

            $hash = Get-FileHashSHA256 $launcher


            Write-Log "SHA256: $hash"


            if (-not (Is-TrustedScript $hash)) {

                Write-Log "Blocked untrusted cartridge."

                    return
            }


            Write-Log "Trusted cartridge."


            Start-Process `
                -FilePath "powershell.exe" `
                -ArgumentList @(
                    "-NoProfile",
                    "-ExecutionPolicy", "Bypass",
                    "-WindowStyle", "Hidden",
                    "-File", "`"$launcher`""
                ) `
                -WindowStyle Hidden


            Write-Log "Launched: $launcher"

        }

        catch {

            Write-Log "Failed launching $launcher"
            Write-Log $_.Exception.Message

        }

    }


Write-Log "Event watcher registered."


try {

    while ($true) {

        Wait-Event | Out-Null

    }

}

finally {

    Unregister-Event `
        -SourceIdentifier "PCCartridgeSystem" `
        -ErrorAction SilentlyContinue

    Remove-Job `
        -Name "PCCartridgeSystem" `
        -Force `
        -ErrorAction SilentlyContinue

    Write-Log "Monitor stopped."

}