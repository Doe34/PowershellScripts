get-process "lync" | Stop-Process

$LocationSipFiles = ($env:LOCALAPPDATA + "\microsoft\office\" + (Get-ChildItem $env:LOCALAPPDATA\microsoft\office -directory | Where-Object {$_.name -like "*.*"}).name + "\lync")
$SipProfiles = (Get-ChildItem $LocationSipFiles | Where-Object {$_.name -like "sip*"}).fullname
$SipProfiles | Remove-Item -Force -Confirm:$false -Recurse

start-process "lync"

