$env:Path = "$HOME/.local/bin;" + $env:Path

Import-Module PowerShellGet
Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1
