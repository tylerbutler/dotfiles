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

# Remove some default aliases
# Remove-Item Alias:\gc -Force
# Remove-Item Alias:\gl -Force
# Remove-Item Alias:\gm -Force
# Remove-Item Alias:\gp -Force

function windows_explorer { explorer . }

# I find typing 'chezmoi' awkward
Set-Alias dotfiles chezmoi

# git
Set-Alias git hub
nba g "hub"
nba gb "hub branch"
nba gba "hub branch --all"
nba gcam "hub add -A ; hub commit -m"
nba gco "hub checkout"
nba gd "hub diff"
nba gf "hub fetch"
nba gfa "hub fetch --all --prune"
nba gl "hub pull"
nba glg "hub log --stat"
nba glgg "hub log --graph"
nba glgga "hub log --graph --decorate --all"
nba glgm "hub log --graph --max-count=10"
nba glgp "hub log --stat -p"
nba glo "hub log --oneline --decorate --graph -10"
nba glog "hub log --oneline --decorate --graph"
nba gloga "hub log --oneline --decorate --graph --all"
nba gm "hub merge"
nba gnd "git clean -dn"
nba gndd "git clean -df"
nba gp "hub push"
nba gpf "hub push --force-with-lease"
nba gpo "hub push -u origin HEAD"
nba gr "hub remote"
nba gra "hub remote add"
nba grh "hub reset"
nba grhh "hub reset --hard"
nba grmm "hub remote remove"
nba grv "hub remote -v"
nba gs "hub sync"
nba gsc "hub clone --filter=tree:0"
nba gsi "hub submodule update --init --recursive"
nba gst "hub status -u ."
nba gsu "hub submodule update"
