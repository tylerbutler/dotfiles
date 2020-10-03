Import-Module PowerShellGet
Install-PackageProvider -Name NuGet -Force
Update-Module -Name PowerShellGet

echo "Installing posh-git..."
Install-Module posh-git

echo "Installing oh-my-posh..."
Install-Module oh-my-posh
