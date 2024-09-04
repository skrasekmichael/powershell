Custom powershell profile, scripts, and modules.

You can download and run script in memory using powershell:
```powershell
# example running hw.ps1
iex (iwr https://raw.githubusercontent.com/skrasekmichael/powershell/main/scripts/hw.ps1).Content

# example running move-window.ps1
iex (iwr https://raw.githubusercontent.com/skrasekmichael/powershell/main/scripts/move-window.ps1).Content
```
*Note: some scripts may require modules to run.*
