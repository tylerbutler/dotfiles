# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module PowerShellGet
Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1

# Prompt
Import-Module oh-my-posh
Set-PoshPrompt -Theme ~/.tylerbu.omp.json

Set-Variable -name DefaultUser 'tylerbu'

# Starship
# Invoke-Expression (&starship init powershell)

