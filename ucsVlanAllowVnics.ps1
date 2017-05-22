<#
.SYNOPSIS
    Alow vlans on vnics
.DESCRIPTION
    This will allow vlans on the vnics, the required information will be requested from the script
    via a csv file.
.NOTES
    File Name      : ucsVlanAllowVnics.ps1
    Author         : gajendra d ambi
    Date           : May 2017
    Prerequisite   : PowerShell v4+, powertool 1.4+ over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: github.com/MrAmbiG
#>
#Start of Script
Connect-Ucs #  connect to ucs

Write-Host "
A CSV file will be opened (open in excel/spreadsheet)
populate the values,
save & close the file,
Hit Enter to proceed
" -ForegroundColor Blue -BackgroundColor White
$csv = "$PSScriptRoot/addhosts.csv"
get-process | Select-Object vnicTemplate,Vlan | Export-Csv -Path $csv -Encoding ASCII -NoTypeInformation
Start-Process $csv
Read-Host "Hit Enter/Return to proceed"

$csv = Import-Csv $csv
 foreach ($line in $csv) {
  $vnicTemplate = $($line.vnicTemplate)
  $Vlan  = $($line.Vlan)
  Get-UcsOrg -Level root  | Get-UcsVnicTemplate -Name $vnicTemplate | Add-UcsVnicInterface -ModifyPresent -DefaultNet "false" -Name $vlan 
 }

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black
#End of script