# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module PowerShellGet

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1

# Prompt
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme tylerbu
Set-Variable -name DefaultUser 'tylerbu'

# Starship
# Invoke-Expression (&starship init powershell)

