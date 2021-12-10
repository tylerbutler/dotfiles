$packages = get-content ~/.default-python-packages
$cmd = $packages | Join-String -Separator " " | ForEach-Object{ "pip install $_" }

Write-Output $cmd

Invoke-Expression "& $cmd"
