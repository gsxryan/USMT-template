<# 
USMT Portable Migration Tool

Gather and restore only the bare minimum from the old user profiles
C:\Users\ All Documents,Desktop,etc [User Accounts that have logged in anytime, Excluding Public Desktop]
C:\ [Custom Non-Standard Folders, excluding system folders]
Chrome and Firefox User States (favorites)

Export User Contents to MIG file on USB Drive from old machine
Import User Contents from MIG file on USB Drive to New machine

Assumptions:
1) USMTx64 folder is located next to USMT.exe
    EX: D:\USMT\USMT.exe
        D:\USMT\USMTx64\ [scanstate.exe loadstate.exe, etc]
    OR: on the root of D:\ and D:\USMTx64

#>
#Clear CurrentDir failsafe
$CurrentDrMidPath=$null
$CurrentDrLocation=$null
$CurrentDrPostPath=$null

#Disable USB Selective Suspend for Attached USB Devices
#If this is not done, the USB drive will sometimes disconnect causing the job to fail
#Plugged In: Disabled
Invoke-Command -ScriptBlock {powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0}
#On Battery: Disabled
Invoke-Command -ScriptBlock {powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0}
#On Device Manager USB Mass Storage Power Saving
$hubs = Get-WmiObject Win32_USBHub
foreach ($usbdevice in $hubs)
{ $powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | where {$_.InstanceName -match [regex]::Escape($usbdevice.PNPDeviceID)}

if ($powerMgmt.Enable -eq $true)
{
    $powermgmt.Enable = $False
    $powermgmt.psbase.Put() }}

$LogServer = "\\logserver.contoso.com"

#Determine the Current Directory
$CurrentDrLetter = (Get-Location).Drive.Name 
$CurrentDrLocation = (Get-Location).Drive.CurrentLocation

if (!$CurrentDrLocation) 
    {$CurrentDrMidPath = ":\"}
else
    {$CurrentDrMidPath = ":\"; $CurrentDrPostPath = "\"}

$CurrentDir = echo $CurrentDrLetter$CurrentDrMidpath$CurrentDrLocation$CurrentDrPostPath

    #Get Current Date and Time
    $Date = Get-Date -Format d
    $Time = Get-Date -Format T

Write-Host "USMT Portable Migration Tool v1.0" -ForegroundColor Cyan
Write-Host "REMINDER: Did you Run As Admin?" -ForegroundColor Red

#Ask for DrivePath to USMTtool
$MIGName = Read-Host "Please enter the username to backup/restore"

#If User Does not exist, begin Scanstate - If it does exist, begin Loadstate
$UserExist = Test-Path $CurrentDir`USMT-Data-$MIGName\USMT
If ($UserExist -eq 0) 
{
#Checking Current machine for Non-Standard software list
Write-Host "Helping you find a list of software that may need to be migrated manually."
Start-Process -FilePath powershell.exe -ArgumentList "-windowstyle hidden -ExecutionPolicy bypass -File `"$CurrentDir`USMTx64\FindNonStandardSoftware.ps1`""

Write-Host " 

"
Write-Host "$CurrentDir`USMT-Data-$MIGName not detected."  
Write-Host "Press Enter to Create Folder, and collect data from OLD Machine." -ForegroundColor Green
Write-Host "If you typed the USMT-Data-$MIGname in wrong, press CTRL+C and start over."
pause

#Create MIGPath if it does not exist
Write-Host "Creating folder USMT-Data-$MigName"
New-Item "$CurrentDir`USMT-Data-$MigName" -ItemType Directory -ErrorAction SilentlyContinue

#ScanState and Save MIG data [Logged In As Admin]
#To further restrict usernames to only specified user use /ui:"Contoso\$MIGName"
#To further restrict usernames to active in last 90 days use /uel:90
Start-Process -FilePath $CurrentDir`USMTx64\Scanstate.exe -ArgumentList "$CurrentDir`USMT-Data-$MIGName /o /c /config:$CurrentDir`USMTx64\Config_min.xml /i:$CurrentDir`USMTx64\MigAppMinChromeFF.xml /i:$CurrentDir`USMTx64\migdocs.xml /i:$CurrentDir`USMTx64\ExcludeFolders.xml /localonly /l:$CurrentDir`USMT-Data-$MigName\scanstate.log /listfiles:$CurrentDir`USMT-Data-$MigName\filelist.log /ue:*\EXCLUDEDUSER* /ue:*\ADMIN* /ue:*\Admini* /ue:*\Default* /ue:*\NetworkService /ue:*\Temp* /ue:*\Default*"
#Invoke-Expression 'cmd /c start cmd -Command {$CurrentDrLetter`:\$CurrentDrLocation\`USMTx64\Scanstate.exe $CurrentDrLetter`:\$CurrentDrLocation\`USMT-Data-$MIGName /o /c /i:$CurrentDrLetter`:\$CurrentDrLocation\`USMTx64\miguser.xml /i:$CurrentDrLetter`:\$CurrentDrLocation\`USMTx64\migdocs.xml /localonly /l:$CurrentDrLetter`:\$CurrentDrLocation\`USMT-Data-$MigName\scanstate.log}'

#Wait for Success or Error Messages
Write-Host " 

" 
Write-Host "If you notice it stops for a long time, try pressing enter on each command window to resume"
Write-Host "Waiting for Complete message..." -ForegroundColor Cyan

sleep 5
#Add Telemetry
Add-Content $LogServer\logs\USMT\$env:username.log "ScanState, $Date, $Time, $env:COMPUTERNAME, $MigName"

#Monitor for completion messages in logfile
Get-Content $CurrentDir`USMT-Data-$MigName\scanstate.log -wait | Where-Object { ($_ -Match "Administrator privileges") -or ($_ -match "Success") -or ($_ -match "completed") } | ForEach-Object { Write-Host $_}
}


else
{
Write-Host " 

"
write-host "$CurrentDir`USMT-Data-$MIGName Exists, Continuing to LoadState."
Write-Host "You should be on the NEW machine." -ForegroundColor Cyan
Write-Host "If you need to reload data from the OLD Machine, Delete $CurrentDir`USMT-Data-$MigName folder and start over."
Write-Host "CTRL+C to quit"
pause

#Setup Printers to be migrated on Users' first logon [removed due to a bug, it will prevent old printers from importing on login - Tried Start-Job with delay on login, but that does not work]
#tested using Local Machine GPO, but that will always run on every login, so it's too intrusive.  Rolling this back to SCCM deployment when the old print server is migrating.
      #detect if machine has specific prefix
<#      If ($env:COMPUTERNAME -match "PREFIX")
        {
        Write-Host "Copying Script to force each usersnetwork printers to migrate to printserver02 upon first login"
        #Copy PrinterMigration.ps1 script to UTILS (locate in USMTx64)
        Copy-Item "$CurrentDir`USMTx64\PrinterMigration.ps1" -Destination "C:\Apps" -Force
        
        #Set Registry entry to migrate printers on users' first login
            new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\PrintMig" -Force
            new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\PrintMig" -name "(Default)" -propertytype String -value "Network Printers Migration" -Force
            new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\PrintMig" -name "StubPath" -propertytype String -value "powershell.exe -windowstyle hidden -ExecutionPolicy bypass -File `"C:\Apps\PrinterMigration.ps1`"" -Force
            new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\PrintMig" -name "Version" -propertytype String -value "1" -Force
            
        }
      else {Write-Host "Your location is not setup to reconfigure network printers at this time.  Contact Help Desk or your local IT Admins if you need migrated network printers"
            }#>

#Telemetry
Add-Content $LogServer\logs\USMT\$env:username.log "LoadState, $Date, $Time, $env:COMPUTERNAME, $MigName"
   
#Loadstate [Logged in As Admin]
Start-Process -FilePath $CurrentDir`USMTx64\Loadstate.exe -ArgumentList "/c /config:$CurrentDir`USMTx64\Config_min.xml /i:$CurrentDir`USMTx64\MigAppMinChromeFF.xml /i:$CurrentDir`USMTx64\migdocs.xml /i:$CurrentDir`USMTx64\ExcludeFolders.xml $CurrentDir`USMT-Data-$MIGName /all /lac:LocalAccountPassword! /progress:$CurrentDir`USMT-Data-$MigName\progress.log /l:$CurrentDir`USMT-Data-$MigName\load.log"
Write-Host "Watching Verbose Status log..." -ForegroundColor Cyan
sleep 5
Get-Content $CurrentDir`USMT-Data-$MigName\progress.log -wait
}
