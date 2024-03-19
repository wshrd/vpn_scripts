$Logfile = "logfile.log"
$LogPath = "Path:\to\log\file\"
#Write log function
function WriteLog($LogString) {
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    $LogMessage | Out-File -FilePath $LogPath$LogFile -Append -Encoding utf8
    }
# Get users in VPN groups
$VPNUsers = Get-ADGroupMember 'VPN_Group' -Recursive | ? {$_.objectClass -eq "user"}
$VPNGroups = Get-ADGroupMember 'VPN_Group' | ? {$_.objectClass -eq "group"}
# Get date
$CurrDate = (Get-Date).ToString("dd.MM.yyyy")
$msg = ""
# Check expired date
foreach($User in $VPNUsers) {
    $ExpirationDate = Get-ADuser $User.SamAccountName -Properties Description | select -ExpandProperty Description
    If ($ExpirationDate -eq $CurrDate) {
        foreach ($Group in $VPNGroups) {
# Set Description        
            Remove-ADGroupMember -Identity $Group.Name -Members $User.SamAccountName -Confirm:$false
            Set-ADUser $User.SamAccountName -Description 'VPN Expired'
        }
    $msg = "Пользователь " + $User.Name + " удален из групп VPN"
    WriteLog $msg
    }
}
