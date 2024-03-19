## Power Shell scripts for manage vpn access 
###  Script add__vpn_gui.ps1
***
Adding a user to a VPN group before a certain date. GUI version

### Script add__vpn_tui.ps1
***
Adding a user to a VPN group before a certain date. TUI version.

ConsoleGridView is used. Working in Power Shell in Linux terminal.

Required Microsoft.PowerShell.ConsoleGuiTools to work.
```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools
```
### Script remove_vpn.ps1
***
Removing users from VPN groups after the granted access expires. Executed from the scheduler on one of the domain controllers.

### Script vpn_info.ps1
***
Distribution of a list of users in groups to VNP, administrator and security service.

Executed from the scheduler on one of the domain controllers
