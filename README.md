# USMT-template
Microsoft User State Migration Tool.  Utilizing example configuration to optimize the User and Admin experience.  

### Context
1. This was created before OneDrive was optimized for Desktop backup and restore where transfer speeds are no longer as essential for optimizing T2 workflows.
2. This includes data directories that are not in standard OneDrive Protected folders (ALL C:\USERcreated-dirs)

 One Click actions.  The goal is to create a standard with zero drift, so technicians are not stuck deciding how to backup a users machine in a custom manner, greatly accelerating the pace for desktop migration completion.  Service tickets post migration are also greatly reduced due to grabbing more custom directories, settings, etc as detailed below.
Additional strategies include copying data as quickly as possible using USB 3.0 & SSD. Resulting in 5-20x reduced time for machine processing.  Additionally, this enables remote servicing, so less on-site presence is required.

```
1Gb Network Data transfer limitations
VS
5-20Gb USB 3+ SSD Transfer
```

Many thanks to Ehlertech for the publicly available XML References.  These were modified to build this custom solution.
https://ehlertech.com/customxmls/

NOTE: USMT.exe is a binary compiled from sourcecode/USMT.ps1 using Powershell to EXE compiler.  The reason for this is to make execution of the script less steps for T2, and better standardization with the mobility of mounted drives / USB.
### How to Build

Clone repository
Source Microsoft Binaries
install the Windows ADK from https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit, and browse to the folder that contains scanstate.exe and loadstate.exe (usually C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\User State Migration Tool), and make a copy. 
Build this tool into EXE: https://github.com/MScholtes/PS2EXE
Or, download the Release listed to the right.

### How to Use

Copy the contents to your USB Drive.  Use the Root of D:\ or,
	
	D:\USMT.exe
	D:\USMTx64/*

        On the Old machine:
            1. Right Click > Run as Admin on USMT.exe
            2. Enter the Foldername identification (username)
            3. NonStandard Software Installed appears (not the most accurate, but can help)
                Backup commences, Wait for a complete message
                Note the Accounts being added/processed.
            4. Close and safely remove the USB Drive
                
        On the new machine:
            1. Right Click > Run as Admin on USMT.exe
            2. Enter the Foldername identification (username)
            3. Restore commences, You can watch status & Wait for a complete message
            4. Close and safely remove USB drive

# Features
- When the user logs in, Desktop looks nearly identical to the previous machine state.
- Migrates all OneDrive UNprotected folders C:\ {Custom Folders} -(excludes system folders)
- Migrates all Users Chrome / Firefox bookmarks, favorites, active tabs
- Migrates Networked Printers and settings (local printers are not added yet)
- Migrate Accessibility settings
- Disable USB Selective Suspend for Attached USB Devices, so it doesn’t turn off during Backup or Restore stage.
- Display the software that differs from standard image: identify what to reinstall on the new machine (Apps are not migrated, but settings in the profiles are :AppData)
- Ask for Username to prompt for folder management
- Back up all Domain User accounts on the machine to anticipate multiple user, except for admin/system/select local accounts

# Notes
- Must copy and run from root of an USB device or physical media (D:\, Mounted Network drive, etc)
- Must Run as Administrator on USMT.exe
- Sourcefiles for review are located in USMTx64\sourcecode\USMT.ps1

# Known Issues
- Currently only supports 64-bit processors. (x86 can easily be requested)
- Cannot run from UNC Path (Must run from USB or Physical attached storage (D:, etc)

# Default XML changes

     v0.9 - Fixed Issues:

1 .USB drives turning off, interrupt during transfers, Added Power Settings to Disable USB Selective Suspending (power saving)

2. Feature: edit $CurrentDir = (Get-Location).Drive.name and associations to be able to move the repo around

        v0.8 - 	Fixed Issues:

3. Desktop background migration is good if it was custom set.  However, if it was default the background will be set to the windows 7 look.  Taking out desktop background migration

Added Configurations:

1. Allowed Public Folder due to some program data (Bionumerics).
2. excluded Public Desktop (to remove duplicate remote tools folder, and old broken installed shortcuts) [excludefolders.xml + config_min.xml]
```<pattern type="File">%CSIDL_COMMON_DESKTOPDIRECTORY%\* [*]</pattern>```
3. Added exclusion for desktop background image (do not migrate the Win7 default background or themes)
4. removed a lot of other components from migration that could conflict with Win10 image state, **The goal is bare minimum migration to improve speed, and not modify standard Win10 image state.**

		-Config_min.xml
		-<component displayname="Microsoft-Windows-uxtheme" migrate="no" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-uxtheme/microsoft-windows-uxtheme/settings"/>
	        -<component displayname="Microsoft-Windows-themeui" migrate="no" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-themeui/microsoft-windows-themeui/settings"/>

5. Added Chrome/Firefox favorites/settings Migration to MigAppMinChromeFF.xml:
6. Added Log that lists all files migrated for verification: /listfiles:{USMT-Data-USERname\filelist.log}
7. Excluded additional files extensions on the root of C: ExcludeFolders.xml
```
-<pattern type="File">C:\ [*.bot]</pattern>
-<pattern type="File">C:\ [*.dat]</pattern>
-<pattern type="File">%SYSTEMDRIVE%\Temp\* [*]</pattern>
```