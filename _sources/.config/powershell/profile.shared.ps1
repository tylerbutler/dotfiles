$env:Path = "$HOME/.local/bin;" + $env:Path
$env:Path = "$HOME/scoop/apps/python/3.9.5/Scripts;" + $env:Path

Import-Module PowerShellGet
Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
. $HOME/.aliases.ps1

fnm env --use-on-cd | Out-String | Invoke-Expression

# zoxide integration
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell) -join "`n"
})
