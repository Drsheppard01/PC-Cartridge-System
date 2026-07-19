# Steam Game Cartridge Trust Monitor (Windows)

$TrustDir = Join-Path $env:LOCALAPPDATA "SteamGameCartridge"
$TrustFile = Join-Path $TrustDir "trusted_scripts.sha256"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$Green = "Green"
$Red = "Red"


if (-not (Test-Path $TrustDir)) {
    New-Item -ItemType Directory -Path $TrustDir -Force | Out-Null
}

if (-not (Test-Path $TrustFile)) {
    New-Item -ItemType File -Path $TrustFile -Force | Out-Null
}



while ($true) {


    $FoundScript = $null
    $FoundDrive = $null


    # Find launch.ps1 on removable drives
    $Drives = Get-PSDrive -PSProvider FileSystem


    foreach ($Drive in $Drives) {

        if (-not $Drive.Root) {
            continue
        }


        $Candidate = Join-Path $Drive.Root "launch.ps1"


        if (Test-Path $Candidate) {

            $FoundScript = $Candidate
            $FoundDrive = $Drive.Root

            break
        }
    }



    if (-not $FoundScript) {

        Clear-Host

        Write-Host ""
        Write-Host " Insert cartridge to check the trust state..."
        Write-Host " (Press E to exit.)"


        for ($i = 0; $i -lt 30; $i++) {

            if ([Console]::KeyAvailable) {

                $Key = [Console]::ReadKey($true)

                if ($Key.Key -eq "E") {

                    Clear-Host
                    & "$RootDir\cartridge-windows.ps1"
                    exit 0
                }
            }

            Start-Sleep -Milliseconds 100
        }


        continue
    }



    $DriveLetter = $FoundDrive.Substring(0,1)

    $DriveInfo = Get-Volume -DriveLetter $DriveLetter

    $Label = $DriveInfo.FileSystemLabel

    if ([string]::IsNullOrWhiteSpace($Label)) {
        $Label = "Unknown"
    }



    $Hash = (
        Get-FileHash `
            -Path $FoundScript `
            -Algorithm SHA256
    ).Hash.ToLower()



    Clear-Host


    Write-Host ""
    Write-Host " Cartridge found!"
    Write-Host ""
    Write-Host " Drive:  $FoundDrive"
    Write-Host " Label:  $Label"
    Write-Host " Script: $FoundScript"
    Write-Host ""
    Write-Host " SHA256:"
    Write-Host " $Hash"
    Write-Host ""



    $TrustedHashes = Get-Content $TrustFile



    if ($TrustedHashes -contains $Hash) {


        Write-Host " State: trusted" -ForegroundColor $Green

        Write-Host ""

        $Confirm = Read-Host " Stop trusting this script? (y/N)"

        if ([string]::IsNullOrWhiteSpace($Confirm)) {
            $Confirm = "N"
        }



        switch ($Confirm.ToLower()) {

            "y" {

                $TrustedHashes |
                    Where-Object { $_ -ne $Hash } |
                    Set-Content $TrustFile

                Write-Host ""
                Write-Host " Trust removed." -ForegroundColor $Red

            }


            default {

                Write-Host ""
                Write-Host " Skipped."

            }

        }


    }

    else {


        Write-Host " State: not trusted" -ForegroundColor $Red

        Write-Host ""

        $Confirm = Read-Host " Trust this script? (Y/n)"

        if ([string]::IsNullOrWhiteSpace($Confirm)) {
            $Confirm = "Y"
        }



        switch ($Confirm.ToLower()) {


            "y" {

                Add-Content `
                    -Path $TrustFile `
                    -Value $Hash

                Write-Host ""
                Write-Host " Script trusted." -ForegroundColor $Green

            }


            "yes" {

                Add-Content `
                    -Path $TrustFile `
                    -Value $Hash

                Write-Host ""
                Write-Host " Script trusted." -ForegroundColor $Green

            }


            default {

                Write-Host ""
                Write-Host " Skipped."

            }

        }

    }



    Write-Host ""
    Write-Host " Remove the cartridge now..."

    Start-Sleep -Seconds 2



    # Wait until cartridge is removed
    while (Test-Path $FoundScript) {

        Start-Sleep -Seconds 2

    }



    Clear-Host

}