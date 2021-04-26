Import-Module PowerShellGet
Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1

# Prompt
Write-Output "Setting prompt..."
Import-Module oh-my-posh
Set-PoshPrompt -Theme $HOME/.tylerbu.omp.json

Set-Variable -name DefaultUser 'tylerbu'

# Starship
# Invoke-Expression (&starship init powershell)
