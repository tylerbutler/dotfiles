# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

. $HOME/.local/share/chezmoi/_sources/.config/powershell/profile.shared.ps1

. $HOME/.local/share/chezmoi/_sources/.config/powershell/prompt.ps1
