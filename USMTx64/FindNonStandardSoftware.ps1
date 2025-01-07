#Evaluate Non-Standard Software Installed on this machine.

#Populate a New Base Image List from your golden image: (Get-WmiObject -Class Win32_Product).IdentifyingNumber

$LogServer = "\\logserver.contoso.com"
$Table = $null

Write-Host "Getting Software list, please wait..."

$Table = Get-WmiObject -Class Win32_Product | where {$_.IdentifyingNumber -ne "{GUID1}"`
-and $_.IdentifyingNumber -ne "{GUID2}"`
-and $_.IdentifyingNumber -ne "{ETC}"`
} | Format-Table -Property IdentifyingNumber,Name,Vendor -AutoSize | Out-String -Width 4096

$Table
    $Table | Out-File $LogServer\logs\Software\$env:COMPUTERNAME.log

Start-Process "$env:windir\explorer.exe" -ArgumentList "$LogServer\logs\Software\$env:COMPUTERNAME.log"