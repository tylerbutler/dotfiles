$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
$absPath = Resolve-Path ../../_fonts
Write-Output "Listing fonts from $absPath"
Get-ChildItem $absPath/*.ttf -Recurse | %{ $fonts.CopyHere($_.fullname) }
