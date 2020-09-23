# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Prompt
# Import-Module posh-git
# Import-Module oh-my-posh
Set-Theme tylerbu
Set-Variable -name DefaultUser 'tylerbu'

# Aliases and their functions
function windows_explorer { explorer . }

New-Alias dotfiles chezmoi
New-Alias e windows_explorer
New-Alias ex explorer
Set-Alias git hub

# git aliases
Set-Alias g git
Set-Alias gst "git status"

Invoke-Expression (&starship init powershell)
