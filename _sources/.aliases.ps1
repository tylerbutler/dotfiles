# Aliases and their functions

# Thanks to https://stackoverflow.com/a/2486303
function New-BashStyleAlias([string]$name, [string]$command)
{
    $prefix = "echo `"$command`"`n"
    $sb = [scriptblock]::Create($prefix + $command)
    Set-Item "Function:\global:$name" -Value $sb | Out-Null
}
Set-Alias nba New-BashStyleAlias

function windows_explorer { explorer . }

# I find typing 'chezmoi' awkward
Set-Alias dotfiles chezmoi

# git
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
nba glod "hub log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'"
nba glog "hub log --oneline --decorate --graph"
nba gloga "hub log --oneline --decorate --graph --all"
nba glol "hub log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'"
nba glola "hub log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --all'"
nba glols "hub log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --stat'"
nba gp "hub push @args"
nba gpf "hub push --force-with-lease @args"
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