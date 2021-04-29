$env:Path = "$HOME/.local/bin;" + $env:Path

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
