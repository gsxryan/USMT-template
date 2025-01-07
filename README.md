# USMT-template
Microsoft User State Migration Tool.  Utilizing example configuration to optimize the User and Admin experience.  

### Context
1. This was created before OneDrive was optimized for Desktop backup and restore where transfer speeds are no longer as essential for optimizing T2 workflows.
2. This includes data directories that are not in standard OneDrive Protected folders (ALL C:\USERcreated-dirs)

 One Click actions.  The goal is to create a standard with zero drift, so technicians are not stuck deciding how to backup a users machine in a custom manner, greatly accelerating the pace for desktop migration completion.  Service tickets post service are also greatly reduced due to grabbing more custom directories, settings, etc as detailed below.
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


### How to Use

Copy the contents to your USB Drive.  Use the Root of D:\ or,
	
	D:\USMT.exe
	D:\USMTx64/*

        On the Old machine:
            1. Right Click > Run as Admin on USMT.exe
            2. Enter the Foldername identification (username)
            3. NonStandard Software Installed appears (its not the most accurate, but can help)
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