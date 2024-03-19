Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
#Set log file path
$Logfile = "logfile.log"
$LogPath = "Path:\to\log\file\"
#Write log function
function WriteLog($LogString) {
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    $LogMessage | Out-File -FilePath $LogPath$LogFile -Append -Encoding utf8
    }
#Exit on error function
function ExitErr {
    $MSG = "Пользователь не выбран." 
    [Microsoft.VisualBasic.Interaction]::MsgBox("$MSG", "OKOnly,SystemModal,Information", "Title")
    exit
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
#Select users
$Susrs = Get-ADUser -SearchBase $OU.DistinguishedName -properties Name, SamAccountName, Description -Filter * | Select Name, SamAccountName, Description | Out-GridView -Title "Выберите пользователя или несколько пользователей(Пробелом)" -OutputMode Multiple
if ( $Susrs -eq $null ) { ExitErr }
#Select date from calendar for all users
$form = New-Object Windows.Forms.Form -Property @{
    StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    Size          = New-Object Drawing.Size 243, 230
    Text          = 'Выберите дату'
    Topmost       = $true
}
$calendar = New-Object Windows.Forms.MonthCalendar -Property @{
    ShowTodayCircle   = $false
    MaxSelectionCount = 1
}
$form.Controls.Add($calendar)
$okButton = New-Object Windows.Forms.Button -Property @{
    Location     = New-Object Drawing.Point 38, 165
    Size         = New-Object Drawing.Size 75, 23
    Text         = 'OK'
    DialogResult = [Windows.Forms.DialogResult]::OK
}
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)
$cancelButton = New-Object Windows.Forms.Button -Property @{
    Location     = New-Object Drawing.Point 113, 165
    Size         = New-Object Drawing.Size 75, 23
    Text         = 'Cancel'
    DialogResult = [Windows.Forms.DialogResult]::Cancel
}
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)
$result = $form.ShowDialog()
if ($result -eq [Windows.Forms.DialogResult]::OK) {
    $description = $calendar.SelectionStart
    $Sds = $($description.ToShortDateString())
    $Sdes = "$Sds"
    $msglg =""
    foreach ($Susr in $Susrs) {
    #Set description
    Set-ADUser $Susr.SamAccountName -Description $Sdes
    Add-ADGroupMember -Identity $Vgroup -Members $Susr.SamAccountName -Confirm:$false
    $msglg =  "Пользователь " + $Susr.Name + " добавлен в группу "  + $Vgroup + " до " + $Sdes
    WriteLog $msglg
    }
}
#Info message on finish
$msg=""
foreach ($Susr in $Susrs) { $msg = $msg + "Пользователь " + $Susr.Name+ " добавлен в группу $Vgroup до $Sdes `n" }
[Microsoft.VisualBasic.Interaction]::MsgBox("$msg", "OKOnly,SystemModal,Information", "Result Info")
