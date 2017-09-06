$path= Join-Path -Path $env:HOMEDRIVE -ChildPath $env:HOMEPATH
$path = $path + '\Desktop\Watchdoc*.csv'
"sep=,`n" + (Get-Content $path | Out-String) | Set-Content $path
