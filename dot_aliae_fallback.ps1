Set-Alias -Name a -Value "aliae"
Set-Alias -Name g -Value "git"
Set-Alias -Name j -Value "just"
Set-Alias -Name fb -Value "~/code/FluidFramework/fluid-build-cache/build-tools/packages/build-tools/bin/fluid-build"
Set-Alias -Name r -Value "repoverlay"
Set-Alias -Name saill -Value "~/code/tools-monorepo/packages/sail/bin/run.js"
Set-Alias -Name flubber -Value "~/code/FluidFramework/build-tools/packages/build-cli/bin/run.js"
Set-Alias -Name :q -Value "exit"
Set-Alias -Name cls -Value "clear"
function reboot() {
	sudo shutdown -r now $args
}
function reset-time() {
	sudo ntpdate -sb time.nist.gov $args
}
function zshconfig() {
	$EDITOR ~/.zshrc $args
}
function zshrc() {
	$EDITOR ~/.zshrc $args
}
Set-Alias -Name dotfiles -Value "chezmoi"
Set-Alias -Name df -Value "chezmoi"
function pbcopy() {
	xclip -selection clipboard $args
}
function pbpaste() {
	xclip -selection clipboard -o $args
}
function pubkey() {
	more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.' $args
}
Set-Alias -Name cdr -Value "cd-gitroot"
function mkdir() {
	mkdir -p $args
}
function md() {
	mkdir -p $args
}
Set-Alias -Name rd -Value "rmdir"
function ..() {
	cd .. $args
}
function ...() {
	cd ../.. $args
}
function ....() {
	cd ../../.. $args
}
function .....() {
	cd ../../../.. $args
}
function ......() {
	cd ../../../../.. $args
}
function 1() {
	cd -1 $args
}
function 2() {
	cd -2 $args
}
function 3() {
	cd -3 $args
}
function 4() {
	cd -4 $args
}
function 5() {
	cd -5 $args
}
function 6() {
	cd -6 $args
}
function 7() {
	cd -7 $args
}
function 8() {
	cd -8 $args
}
function 9() {
	cd -9 $args
}
function l() {
	ls -lFh $args
}
function la() {
	ls -lAFh $args
}
function ll() {
	ls -l $args
}
function lsa() {
	ls -lah $args
}
function lr() {
	ls -tRFh $args
}
function lt() {
	ls -ltFh $args
}
function ldot() {
	ls -ld .* $args
}
function lS() {
	ls -1FSsh $args
}
function lart() {
	ls -1Fcart $args
}
function lrt() {
	ls -1Fcrt $args
}
function lsr() {
	ls -lARFh $args
}
function lsn() {
	ls -1 $args
}
function du() {
	du -hd1 | sort -h $args
}
function grep() {
	grep --color $args
}
function rmlint() {
	\rmlint -g -C $args
}
function rsync-copy() {
	rsync -avz --progress -h $args
}
function rsync-move() {
	rsync -avz --progress -h --remove-source-files $args
}
function rsync-update() {
	rsync -avzu --progress -h $args
}
function rsync-synchronize() {
	rsync -avzu --delete --progress -h $args
}
function gco() {
	git checkout $args
}
function gcam() {
	git commit --all --message $args
}
function grhh() {
	git reset --hard $args
}
function ga() {
	git add $args
}
function gp() {
	git push $args
}
function gba() {
	git branch --all $args
}
function gwta() {
	git worktree add $args
}
function grh() {
	git reset $args
}
function gfa() {
	git fetch --all $args
}
function gpf() {
	git push --force-with-lease $args
}
function gl() {
	git pull $args
}
function gd() {
	git diff $args
}
function gb() {
	git branch $args
}
function gst() {
	git status $args
}
function gaa() {
	git add --all $args
}
function gcb() {
	git checkout -b $args
}
function gcm() {
	git checkout main $args
}
function gcan!() {
	git commit --all --no-edit --amend $args
}
function glo() {
	git log --oneline --decorate -10 $args
}
function glog() {
	git log --oneline --decorate $args
}
function glol() {
	git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" $args
}
function glola() {
	git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all $args
}
function gsta() {
	git stash push $args
}
function gstp() {
	git stash pop $args
}
function gstl() {
	git stash list $args
}
function gpr() {
	git pull --rebase $args
}
function gpra() {
	git pull --rebase --autostash $args
}
function gpsup() {
	git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD 2>/dev/null) $args
}
function gdca() {
	git diff --cached $args
}
function gra() {
	git remote add $args
}
function grbi() {
	git rebase --interactive $args
}
function grbm() {
	git rebase main $args
}
function grrm() {
	git remote rm $args
}
function grt() {
	cd "$(git rev-parse --show-toplevel || echo .)" $args
}
function grv() {
	git remote --verbose $args
}
function gbd() {
	git branch -d $args
}
function gbD() {
	git branch -D $args
}
Set-Alias -Name gcd -Value "cd-gitroot"
function glr() {
	git pull --rebase $args
}
function gpo() {
	git push -u origin HEAD $args
}
function gs() {
	hub sync $args
}
function gsv() {
	HUB_VERBOSE=1 hub sync $args
}
function gsc() {
	git clone --filter=tree:0 $args
}
function gnd() {
	git clean -dn $args
}
function gndd() {
	git clean -df $args
}
Set-Alias -Name gui -Value "gitui"
function default-blindspot-packages() {
	xargs blindspot install <~/.default-blindspot-packages $args
}
function default-cargo-crates() {
	xargs cargo install <~/.default-cargo-crates $args
}
function default-eget() {
	xargs eget <~/.default-eget $args
}
function default-nix-packages() {
	xargs nix-env -iA <~/.default-nix-packages $args
}
function default-npm-packages() {
	xargs npm i -g <~/.default-npm-packages $args
}
function extra-npm-packages() {
	xargs npm i -g <~/.extra-npm-packages $args
}
function default-pacman() {
	sudo xargs pacman -Syyu --needed --noconfirm <~/.default-pacman-packages $args
}
function default-python-packages() {
	xargs pip install <~/.default-python-packages $args
}
function zfs-space() {
	zfs list -o space -r deadpool x23 $args
}
function zfs-snaps() {
	zfs list -t snapshot -S creation $args
}
function zfs-sync() {
	syncoid --no-stream --no-sync-snap --create-bookmark $args
}
function zfs-snap-delete() {
	sudo zfs destroy -v $args
}
Set-Alias -Name b -Value "brew"
function bupd() {
	brew update && brew outdated $args
}
function bupg() {
	brew upgrade $args
}
Set-Alias -Name p -Value "pnpm"
function pi() {
	pnpm i $args
}
function pif() {
	pnpm i --frozen-lockfile $args
}
Set-Alias -Name nvm -Value "fnm"
Set-Alias -Name nvs -Value "fnm"
Set-Alias -Name edit -Value "$EDITOR"
function aliases() {
	$EDITOR $HOME/.aliae.yaml $args
}
function refreshenv() {
	source ~/.zshrc $args
}
function aliae-update-fallback() {
	aliae init zsh > /Users/tylerbu/.local/share/chezmoi/dot_aliae_fallback.zsh && aliae init bash > /Users/tylerbu/.local/share/chezmoi/dot_aliae_fallback.bash && aliae init pwsh --print > /Users/tylerbu/.local/share/chezmoi/dot_aliae_fallback.ps1 $args
}
function claude-review() {
	claude --plugins code-review@claude-plugins-official,code-simplifier@claude-plugins-official,commit-commands@claude-plugins-official $args
}
function claude-design() {
	claude --plugins superpowers@claude-plugins-official,frontend-design@claude-plugins-official $args
}
function claude-code() {
	claude --plugins code-review@claude-plugins-official,code-simplifier@claude-plugins-official,commit-commands@claude-plugins-official,superpowers@claude-plugins-official,frontend-design@claude-plugins-official $args
}
function claude-mem() {
	bun "/Users/tylerbu/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs" $args
}
function haiku() {
	claude --model haiku $args
}
function sonnet() {
	claude --model sonnet $args
}
function opus() {
	claude --model opus $args
}