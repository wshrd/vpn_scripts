Import-Module Microsoft.PowerShell.ConsoleGuiTools
$Logfile = "logfile.log"
$LogPath = "/path/to/log/file/"
#Write log function
function WriteLog($LogString) {
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    $LogMessage | Out-File -FilePath $LogPath$LogFile -Append -Encoding utf8
    }
#Import session. Necessary if there is no RSAT on the local PC
$Session = New-PSSession -ComputerName dc_controller_name.domain.local
Import-Module -PSsession $Session -Name ActiveDirectory
#Select organization from OU list
$OU = Get-OrganizationalUnit -SingleNodeOnly -Identity "Accounts" | Select Name, DistinguishedName | Out-ConsoleGridView -OutputMode Single
#Check selection and set vpn group
if ( $OU -like 'ORG1' ) { $Vgroup = "vpn_group_1" }
if ( $OU -like 'ORG2' ) { $Vgroup = "vpn_group_2" }
if ( $OU -like 'ORG3' ) { $Vgroup = "vpn_group_3" }
#Select user
$Susrs = Get-ADUser -SearchBase $OU -properties Name, SamAccountName, Description -Filter * | Select Name, SamAccountName, Description | Out-ConsoleGridView -Title "Select user or users(space)"  
Write-Host "Enter Date in format DD.MM.YYYY"
$Sdes = Read-Host
$msglg = ""
$msg = ""
foreach ($Susr in $Susrs) {
    #Set description
    Set-ADUser $Susr.SamAccountName -Description $Sdes
    #Add to VPN Group
    Add-ADGroupMember -Identity $Vgroup -Members $Susr.SamAccountName -Confirm:$false
    $msglg =  "Пользователь " + $Susr.Name + " добавлен в группу "  + $Vgroup + " до " + $Sdes
    WriteLog $msglg
    }
#Info message
foreach ($Susr in $Susrs) { $msg = $msg + "User " + $Susr.Name+ " add to group $Vgroup before $Sdes`n" }
[Terminal.Gui.Application]::Init()
$ms = [Terminal.Gui.MessageBox]::Query("Info", $msg, @("OK"))
[Terminal.Gui.Application]::shutdown()
