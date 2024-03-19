# Select User from vpn groups
$vpn1usr = Get-ADGroupMember  'vpn_group_1' -Recursive | ForEach-Object { Get-ADuser $_.samaccountname -properties Description} | select Name, Description
$vpn2usr = Get-ADGroupMember  'vpn_group_2' -Recursive | ForEach-Object { Get-ADuser $_.samaccountname -properties Description} | select Name, Description
$vpn3usr = Get-ADGroupMember  'vpn_group_3' -Recursive | ForEach-Object { Get-ADuser $_.samaccountname -properties Description} | select Name, Description
# Write to CSV file
$vpn1usr | Export-CSV "./users.csv" -NoTypeInformation -Encoding UTF8 -Delimiter (Get-Culture).TextInfo.ListSeparator
$vpn2usr | Export-CSV "./users.csv" -NoTypeInformation -Encoding UTF8 -Delimiter (Get-Culture).TextInfo.ListSeparator -Append
$vpn3usr | Export-CSV "./users.csv" -NoTypeInformation -Encoding UTF8 -Delimiter (Get-Culture).TextInfo.ListSeparator -Append
# Send mail
Send-MailMessage -From 'vpninfo@domain.ru' -To 'admin@domain.ru' -Cc 'security@domain.ru' -Subject "VPN Users" -Body "Users with VPN Access" -Attachments ./users.csv –SmtpServer 'name_exchange_server.domain.local'
