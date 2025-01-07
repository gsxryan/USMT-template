#Status: Development - not working
#Use only as a template for completion

#PSEXEC ScanState to Local USB Storage
$CurrentDir = (Get-Location).Drive.name
$hostname = "PCName"
$MIGName = "UsersName"

#Copy USMT ScanState Tools to C:\Temp
xcopy $CurrentDir`:\USMTx64\scanstate.exe \\$hostname\c$\Temp\USMT\scanstate.exe*
xcopy $CurrentDir`:\USMTx64\MigDocs.xml \\$hostname\c$\Temp\USMT\MigDocs.xml*
xcopy $CurrentDir`:\USMTx64\migcore.dll \\$hostname\c$\Temp\USMT\migcore.dll*
xcopy $CurrentDir`:\USMTx64\unbcl.dll \\$hostname\c$\Temp\USMT\unbcl.dll*
xcopy $CurrentDir`:\USMTx64\migstore.dll \\$hostname\c$\Temp\USMT\migstore.dll*


#Create MIGPath if it does not exist
Write-Host "Creating folder USMT-Data-$MigName"
New-Item "$CurrentDir`:\USMT-Data-$MigName" -ItemType Directory -ErrorAction SilentlyContinue

#Can't use a RAW UNC path to save to on scanstate.
#it does work with a separate volume on the users' machine, but not on C:\

#Run with /smartcard if your admin account requires MFA
#Execute the ScanState Command Remotely
Start-Process -FilePath  $CurrentDir`:\USMTx64\PsExec.exe -ArgumentList "\\$hostname /e cmd /c (net use Z: \\$env:COMPUTERNAME\$CurrentDir`$\USMT-Data-$MigName && C:\Temp\USMT\scanstate.exe xx /o /c /i:C:\Temp\USMT\miguser.xml /i:C:\temp\USMT\migdocs.xml /i:C:\Temp\USMT\ExcludeWallpaper.xml /localonly /l:C:\Temp\USMT\scanstate.log & pause)" #-Verb "RunAs /smartcard"


#watch the progress and wait for completion
#Wait for Success or Error Messages
Write-Host " " 
Write-Host "If you notice it stops for a long time, try pressing enter on each command window to resume"
Write-Host "Waiting for Complete message..." -ForegroundColor Cyan

sleep 10

#INCOMPLETE!! Monitor for completion messages in logfile
Get-Content $CurrentDir`USMT-Data-$MigName\scanstate.log -wait | Where-Object { ($_ -Match "Administrator privileges") -or ($_ -match "Success") -or ($_ -match "completed") } | ForEach-Object { Write-Host $_}
