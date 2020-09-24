# Aliases and their functions

# Thanks to https://stackoverflow.com/a/2486303
function New-BashStyleAlias([string]$name, [string]$command)
{
    $prefix = "echo `"$command`"`n"
    $sb = [scriptblock]::Create($prefix + $command)
    Set-Item "Function:\global:$name" -Value $sb | Out-Null
}
Set-Alias nba New-BashStyleAlias

# Remove some default aliases
Remove-Item Alias:gl -Force
Remove-Item Alias:gp -Force

function windows_explorer { explorer . }

# I find typing 'chezmoi' awkward
Set-Alias dotfiles chezmoi

# git
nba g "hub @args"
nba gba "hub branch --all"
nba gba "hub branch @args"
nba gco "hub checkout @args"
nba gd "hub diff @args"
nba gfa "hub fetch --all --prune"
nba gl "hub pull @args"
nba glg "hub log --stat"
nba glgg "hub log --graph"
nba glgga "hub log --graph --decorate --all"
nba glgm "hub log --graph --max-count=10"
nba glgp "hub log --stat -p"
nba glo "hub log --oneline --decorate"
nba glog "hub log --oneline --decorate --graph"
nba gloga "hub log --oneline --decorate --graph --all"
nba gp "hub push @args"
nba gpf "hub push --force-with-lease @args"
nba gpo "git push -u origin HEAD"
nba gr "hub remote @args"
nba gra "hub remote add @args"
nba grh "hub reset @args"
nba grhh "hub reset --hard"
nba grmm "hub remote remove @args"
nba grv "hub remote -v"
nba gs "hub sync"
nba gsi "hub submodule update --init --recursive"
nba gst "hub status -u ."
nba gsu "hub submodule update @args"
