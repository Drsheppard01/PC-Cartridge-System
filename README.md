# Disclaimer

This project is a hobby experiment and is not an official Steam product.

Automatic launching depends on your operating system settings and security policies. Some systems may require additional configuration for automounting drives or allowing scripts to run automatically.




# Steam Games Cartridges

<img width="970" height="546" alt="JTDUMcuDBav3BEspNBMw6A-970-80 jpg" src="https://github.com/user-attachments/assets/8c0a8d2b-ce5a-4aa5-9bac-5805016db31f" />

<br/><br/>
Physical game cartridges for your Steam library using 2.5" SATA SSDs.

Turn your digital Steam games into something that feels physical: insert a cartridge, and your PC automatically detects it and launches the configured game or action.

Each cartridge is a simple storage device containing a small launcher script. When inserted, the system detects the cartridge and executes the script file on the drive if it has been classified "trusted". 
Launching a Steam game, opening a game's details page, or running a custom command.

## 3D-Print Files
STEP-Files are available over at MakerWorld: [MakerWorld](https://makerworld.com/en/models/3057977-2-5-ssd-dock-cartridge-system#profileId-3440827)

## Quickstart
### Linux

Clone the repository:

```bash
git clone https://github.com/LewdM3at/Steam-Games-Cartridges.git
```
Enter the project directory:
```bash
cd Steam-Games-Cartridges
```
Run the installer:
```bash
./cartridge-linux.sh
```
<img width="796" height="410" alt="image" src="https://github.com/user-attachments/assets/3b6da377-049a-453b-8dfd-9cd2de70f00a" />

**Installation**<br>
Select menu point 1) Install<br>
The installer will install the required udev rule, systemd service, and launcher helper.

**Trust Scripts**<br>
After you have created a Cartridge with the launch.sh script, add the script to trusted-scripts with menu point 2) Trust Scripts.
It will scan for any connected storage media for the launch.sh script and ask if you want to trust said script:
<img width="574" height="216" alt="image" src="https://github.com/user-attachments/assets/77c0e7cf-ba76-430a-99b0-4d97def11cdf" />

Any script that hasn't been trusted through this process **will NOT be automatically executed**
! If you modify the script later on, you have to re-add it to trusted scripts again.<br>

**Uninstallation:**<br>
Select menu point 4) Uninstall <br>
This will remove everything including the config files and trust scripts list.

### Windows

Download the repo:
1. Click Code → Download ZIP OR download it from [Releases](https://github.com/LewdM3at/Steam-Games-Cartridges/releases)
2. Extract it
3. Right click on cartridge-windows.ps1 -> Run with Powershell

**Installation**<br>
Select menu point 1) Install<br>
The installer will install the required udev rule, systemd service, and launcher helper.

**Trust Scripts**<br>
After you have created a Cartridge with the launch.sh script, add the script to trusted-scripts with menu point 2) Trust Scripts.
It will scan for any connected storage media for the launch.sh script and ask if you want to trust said script.

Any script that hasn't been trusted through this process **will NOT be automatically executed**
! If you modify the script later on, you have to re-add it to trusted scripts again.<br>

**Uninstallation:**<br>
Select menu point 4) Uninstall <br>
This will remove everything including the config files and trust scripts list.


## Supported Storage

The project is designed around **2.5" SATA SSDs**.

However, the same concept may work with other storage devices such as:

- SD cards
- USB flash drives
- External HDDs
- Other removable storage

Compatibility with other storage types is **not guaranteed** and depends on your operating system, filesystem, automount configuration, and hardware.

## How It Works

Each cartridge contains a launcher script (launch.sh/launch.ps1) that will be executed by the helpers (depending on OS).
Configure these scripts to whatever you need with Steam URL Protocol.

### Linux

The Linux version uses three components:

- **udev rule**<br>
The udev rule detects when a new storage partition is connected.<br>
Its only job is to notify systemd that a game cartridge may have been inserted.<br>
It does not execute the cartridge directly.<br>

- **systemd service**<br>
A systemd template service is used to handle cartridge launches.<br>
The template allows the same service to work with any inserted device.<br>
The service starts the launcher helper and passes the detected device name.<br>

- **cartridge-launcher-helper**<br>
The helper script waits for the desktop environment to mount the drive, then searches the cartridge at rool level for: `launch.sh` <br>
If found, it checks the SHA256 sums of said script against the stored trusted-scripts file. <br>
If the SHA256 matches, it executes the script.<br>
Example cartridge:<br>
SSD<br>
└── launch.sh<br>
└── SteamLibrary<br>
The contents of `launch.sh` decide what happens next.

---

#### Windows

The Windows version uses two components:


- **Task Scheduler**<br>
The installer creates a scheduled task that starts the cartridge monitor when the user logs in.<br>
The task keeps the monitor running silently in the background.<br>
- **cartridge-monitor.ps1**<br>
The PowerShell monitor watches for newly inserted storage devices.<br>
When a new drive is detected, it checks the root of the cartridge for: `launch.ps1` <br>
If found, it checks the SHA256 sums of said script against the stored trusted-scripts file. <br>
If the SHA256 matches, it executes the script.<br>
Example cartridge:<br>
SSD<br>
└── launch.ps1<br>
└── SteamLibrary<br>
The contents of `launch.ps1` decide what happens next.
