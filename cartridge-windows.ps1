$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors
$Cyan = "Cyan"

Clear-Host

Write-Host @"
   ██████╗ █████╗ ██████╗ ████████╗██████╗ ██╗██████╗  ██████╗ ███████╗███████╗
  ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝██╔════╝
  ██║     ███████║██████╔╝   ██║   ██████╔╝██║██║  ██║██║  ███╗█████╗  ███████╗
  ██║     ██╔══██║██╔══██╗   ██║   ██╔══██╗██║██║  ██║██║   ██║██╔══╝  ╚════██║
  ╚██████╗██║  ██║██║  ██║   ██║   ██║  ██║██║██████╔╝╚██████╔╝███████╗███████║
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝╚══════╝
"@ -ForegroundColor $Cyan


Write-Host ""
Write-Host "        ╭────────────────────────────────────────╮"
Write-Host "        │      Menu                              │"
Write-Host "        ├────────────────────────────────────────┤"
Write-Host "        │   1) Install                           │"
Write-Host "        │   2) Trust Scripts                     │"
Write-Host "        │   3) Mode                              │"
Write-Host "        │   4) Uninstall                         │"
Write-Host "        │   5) Exit                              │"
Write-Host "        ╰────────────────────────────────────────╯"
Write-Host ""


$Option = Read-Host "     Select option"


switch ($Option) {

    "1" {

        Clear-Host
        Write-Host "Starting installation..."

        Start-Process `
            powershell.exe `
            -Verb RunAs `
            -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptDir\windows\install.ps1`"" `
            -Wait
    }


    "2" {

        Clear-Host
        Write-Host "Starting trust process..."

        powershell.exe `
            -ExecutionPolicy Bypass `
            -File "$ScriptDir\windows\trust-script.ps1"
    }


    "3" {

        Write-Host "Mode selection coming soon..."
    }


    "4" {

        Clear-Host
        Write-Host "Starting uninstall..."

        Start-Process `
            powershell.exe `
            -Verb RunAs `
            -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptDir\windows\uninstall.ps1`"" `
            -Wait
    }


    "5" {

        Write-Host "Exiting..."
        Start-Sleep -Seconds 1
        Clear-Host
        exit
    }


    default {

        Write-Host "Invalid option."
    }
}