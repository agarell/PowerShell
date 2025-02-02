#Detect and remediation script for intune. 
# Checks to see if you're missing the required printer and that you have connection to the print server.
# 2nd part installs the missing printer and sets it to default, it then removes any old printers.

$mappedPrinters = Get-Printer

if ($mappedPrinters.Name -notcontains "\\pg-printsvr\Follow-Me-ARM" -and (Test-Connection print.server.com -Count 1 -Quiet)) {
    Exit 1
} 
else {
    Exit 0
}



######

Add-Printer -ConnectionName "\\pg-printsvr\Follow-Me-ARM" 

if((Test-Path -LiteralPath "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows") -ne $true) {  New-Item "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows' -Name 'Device' -Value '\\pg-printsvr\Follow-Me-ARM,winspool,Ne02:' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows' -Name 'IsMRUEstablished' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows' -Name 'MenuDropAlignment' -Value '1' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows' -Name 'LegacyDefaultPrinterMode' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

$removePrinters = Get-Printer
foreach ($printer in $removePrinters) {
    if ($printer.Name -like "\\pg-printsvr\*" -and $printer.Name -ne '\\pg-printsvr\Follow-Me-ARM') {
        Remove-Printer -Name $printer.Name
    }
}
