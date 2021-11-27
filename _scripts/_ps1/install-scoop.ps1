Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

scoop bucket add extras
scoop bucket add twpayne https://github.com/twpayne/scoop-bucket
