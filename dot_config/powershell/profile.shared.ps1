$env:Path = "$HOME/.local/bin;$HOME/scoop/shims;$HOME/scoop/apps/python/current/Scripts;" + $env:Path

Import-Module -Name Terminal-Icons

Write-Output "Sourcing aliases..."
aliae init pwsh | Invoke-Expression

# zoxide integration
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell) -join "`n"
})

# gitignore.io function
Function gig {
  param(
    [Parameter(Mandatory=$true)]
    [string[]]$list
  )
  $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
  Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
}

#use PSReadLine only for PowerShell and VS Code
if ($host.Name -eq 'ConsoleHost' -or $host.Name -eq 'Visual Studio Code Host' ) {
    #ensure the correct version is loaded
    # Import-Module PSReadline -RequiredVersion 2.2.0
    #ListView currently works only with -EditMode Windows properly
    Set-PSReadLineOption -EditMode Windows
    if ($host.Version.Major -eq 7){
        #only PS 7 supports HistoryAndPlugin
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    else{
        #use history as the prediction source on 5.1
        Set-PSReadLineOption -PredictionSource History
    }
    #add background color to the prediction preview
    Set-PSReadLineOption -Colors @{InlinePrediction = "$([char]0x1b)[36;7;238m]"}
    #change the key to accept suggestions (default is right arrow)
    Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key 'ALT+r'
}

mise activate pwsh | Out-String | Invoke-Expression

