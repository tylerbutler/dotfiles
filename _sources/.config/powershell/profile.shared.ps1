$env:Path = "$HOME/.local/bin;" + $env:Path

Import-Module PowerShellGet
Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1

fnm env --use-on-cd | Out-String | Invoke-Expression
