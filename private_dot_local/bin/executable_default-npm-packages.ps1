npm install -g pnpm

$packages = get-content ~\.default-npm-packages
$cmd = $packages | Join-String -Separator " " | ForEach-Object{ "npm install -g $_" }

Write-Output $cmd

Invoke-Expression "& $cmd"
