# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

. $HOME/.config/powershell/profile.shared.ps1

. $HOME/.config/powershell/prompt.ps1
