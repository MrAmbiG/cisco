<#
.SYNOPSIS
    add vlans to switch
.DESCRIPTION
    this will open up a csv file asking for vlan id and vlan name then it will
    configure the vlans with the following command
    config t;vlan vlanID;name vlanName
.NOTES
    File Name      : nxosAddVlan.ps1
    Author         : gajendra d ambi
    updated        : November 2017
    Prerequisite   : PowerShell v4+ over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: github.com/MrAmbig/
#>

#Start of function
function GetPlink 
{
<#
.SYNOPSIS
    Gets the plink
.DESCRIPTION
    This will make sure plink is either downloaded from the internet if it is not present and if it cannot download
    then it will pause the script till you copy it manually.
.NOTES
    File Name      : GetPlink.ps1
    Author         : gajendra d ambi
    Date           : Audust 2016
    Prerequisite   : PowerShell v4+, over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
    github.com/mrambig
    [source] http://www.virtu-al.net/2013/01/07/ssh-powershell-tricks-with-plink-exe/

#>
$PlinkLocation = $PSScriptRoot + "\Plink.exe"
$presence = Test-Path $PlinkLocation
if (-not $presence) 
    {
    Write-Host "Missing Plink.exe, trying to download...(10 seconds)" -BackgroundColor White -ForegroundColor Black
    Invoke-RestMethod "http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe" -TimeoutSec 10 -OutFile "plink.exe"
    if (-not $presence)
        {
            do
            {
            Write-Host "Unable to download plink.exe, please download and add it to the same folder as this script" -BackgroundColor Yellow -ForegroundColor Black
            Read-host "Hit Enter/Return once plink is present"
            $presence = Test-Path $PlinkLocation
            } while (-not $presence)
        }
    }

if ($presence) { Write-Host "Detected Plink.exe" -BackgroundColor White -ForegroundColor Black }
} #End of function
GetPlink

function nxosVlan 
{
$device = Read-Host "Ip address of the device?"
$user = Read-Host "username?"
$pass = Read-Host "password?"

#Start of Script
Write-Host "
A CSV file will be opened (open in excel/spreadsheet)
populate the values,
save & close the file,
Hit Enter to proceed
" -ForegroundColor Blue -BackgroundColor White
$csv = "$PSScriptRoot/nxosAddVlan.csv"
get-process | Select-Object vlanID,vlanName | Export-Csv -Path $csv -Encoding ASCII -NoTypeInformation
Start-Process $csv
Read-Host "Hit Enter/Return to proceed"

echo y | C:\plink.exe -ssh $user@$device -pw $pass "exit"

$csv = Import-Csv $csv
$first = 'config t ;'
$middle = ''
$last =  'end'
foreach ($line in $csv) {
$vlanID = $($line.vlanID)  
$vlanName = $($line.vlanName)
$middle +=  "vlan $vlanID ; name $vlanName ;"
}
$finalCommand = "$first "+"$middle "+"$last"
$finalCommand >> text.txt
#C:\plink.exe -ssh -v -noagent $device -l $user -pw $pass $finalCommand
}
GetPlink
nxosVlan