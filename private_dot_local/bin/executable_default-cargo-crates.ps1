$packages = get-content ~\.default-cargo-crates
$cmd = $packages | Join-String -Separator " " | ForEach-Object{ "cargo install $_" }

Write-Output $cmd

Invoke-Expression "& $cmd"
