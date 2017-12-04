Function Format-DiskSize() {
[cmdletbinding()]
Param ([long]$Type)
If ($Type -ge 1TB) {[string]::Format("{0:0.00} TB", $Type / 1TB)}
ElseIf ($Type -ge 1GB) {[string]::Format("{0:0.00} GB", $Type / 1GB)}
ElseIf ($Type -ge 1MB) {[string]::Format("{0:0.00} MB", $Type / 1MB)}
ElseIf ($Type -ge 1KB) {[string]::Format("{0:0.00} KB", $Type / 1KB)}
ElseIf ($Type -gt 0) {[string]::Format("{0:0.00} Bytes", $Type)}
Else {""}
} # End of function