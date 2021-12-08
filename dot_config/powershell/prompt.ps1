# Prompt
Write-Output "Setting prompt..."

oh-my-posh --init --shell pwsh --config "$HOME/.config/oh-my-posh/headline-tylerbu.omp.json" | Invoke-Expression

Set-Variable -name DefaultUser 'tylerbu'

# Starship
# Invoke-Expression (&starship init powershell)
