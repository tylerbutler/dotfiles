# Aliases and their functions

# Thanks to https://stackoverflow.com/a/2486303
function New-BashStyleAlias([string]$name, [string]$command) {
  $echo_script = @"
`$str_args = `$args -join " "
echo "$command `$str_args"`n
"@
  $sb = [scriptblock]::Create($echo_script + $command + " @args")
  Set-Item "Function:\global:$name" -Value $sb | Out-Null
}
Set-Alias nba New-BashStyleAlias

function Get-Colors() {
  $colors = [enum]::GetValues([System.ConsoleColor])
  Foreach ($bgcolor in $colors) {
    Foreach ($fgcolor in $colors) {
      Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
    }
    Write-Host " on $bgcolor"
  }
}
Set-Alias colors Get-Colors

# Remove some default aliases
Remove-Item Alias:\gc -Force
Remove-Item Alias:\gl -Force
Remove-Item Alias:\gm -Force
Remove-Item Alias:\gp -Force

function windows_explorer { explorer . }

# I find typing 'chezmoi' awkward
Set-Alias dotfiles chezmoi
Set-Alias df chezmoi

# Set-Alias sudo gsudo

# git
# Set-Alias git hub
nba g "git"
nba gb "git branch"
nba gba "git branch --all"
nba gcam "git add -A ; git commit -m"
nba gco "git checkout"
nba gd "git diff"
nba gf "git fetch"
nba gfa "git fetch --all --prune"
nba gl "git pull"
nba glg "git log --stat"
nba glgg "git log --graph"
nba glgga "git log --graph --decorate --all"
nba glgm "git log --graph --max-count=10"
nba glgp "git log --stat -p"
nba glo "git log --oneline --decorate --graph -10"
nba glog "git log --oneline --decorate --graph"
nba gloga "git log --oneline --decorate --graph --all"
nba glr "git pull --rebase"
nba gm "git merge"
nba gnd "git clean -dn"
nba gndd "git clean -df"
nba gp "git push"
nba gpf "git push --force-with-lease"
nba gpo "git push -u origin HEAD"
nba gr "git remote"
nba gra "git remote add"
nba grh "git reset"
nba grhh "git reset --hard"
nba grmm "git remote remove"
nba grv "git remote -v"
nba gs "hub sync"
nba gsc "git clone --filter=tree:0"
nba gsi "git submodule update --init --recursive"
nba gst "git status -u ."
nba gsu "git submodule update"

nba z "zoxide"

# I use fnm for node management on Linux and mac, but nvs on Windows
nba nvs "fnm"
nba nvm "fnm"
