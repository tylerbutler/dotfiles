# Prompt
Write-Output "Setting prompt..."
# Import-Module oh-my-posh
oh-my-posh --init --shell pwsh --config "$HOME/.headline.omp.json" | Invoke-Expression
# oh-my-posh --init --shell pwsh --config "$HOME/.shanselman.omp.json" | Invoke-Expression
# Set-PoshPrompt -Theme $HOME/.tylerbu.omp.json
# Set-PoshPrompt -Theme $HOME/.headline.omp.json
# Set-PoshPrompt -Theme $HOME/sample.omp.json

Set-Variable -name DefaultUser 'tylerbu'

# Starship
# Invoke-Expression (&starship init powershell)
