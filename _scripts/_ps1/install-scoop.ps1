if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
  scoop config aria2-enabled false
  scoop install git
  scoop bucket add extras
  scoop bucket add twpayne https://github.com/twpayne/scoop-bucket
  scoop bucket add nerd-fonts
} else {
  Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}

