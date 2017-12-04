$path= Join-Path -Path $env:HOMEDRIVE -ChildPath $env:HOMEPATH
$path = $path + '\Dropbox\rd\_Desktop\Watchdoc*.csv'
"sep=,`n" + (Get-Content $path | Out-String) | Set-Content $path
