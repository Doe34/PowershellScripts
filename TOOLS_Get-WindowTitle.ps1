Function Get-WindowTitle ()
{
Get-Process |where {$_.mainWindowTItle} |format-table id,name,mainwindowtitle ľAutoSize
}
Get-WindowTitle