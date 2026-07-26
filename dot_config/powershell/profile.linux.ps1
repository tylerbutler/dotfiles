. $HOME/.config/powershell/profile.shared.ps1

. $HOME/.config/powershell/prompt.ps1

if (Get-Command wt -ErrorAction SilentlyContinue) { Invoke-Expression (& wt config shell init powershell | Out-String) }
