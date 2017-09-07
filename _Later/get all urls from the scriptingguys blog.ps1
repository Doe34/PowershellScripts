$url = "https://blogs.technet.microsoft.com/heyscriptingguy/tag/windows-powershell/page/"
$result = For  ($i = 407 ; $i -le 407 ; $i = $i + 1) {
$content = (Invoke-RestMethod -Uri $url/$i).split("`n") | %{Select-String -InputObject $_ -Pattern "entry-title"} | %{Select-String -InputObject $_ -Pattern "href"}
$content.line | %{(($_ -split "=" |  Select-String -Pattern "http") -split " ") | Select-String -Pattern "http"} 
}
$result | out-file "C:\temp\results.txt" -Append