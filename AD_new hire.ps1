#Path to new hire document
$DocPath = "$env:userprofile\desktop\onboard.docx"

#Open Word document
$Word = New-Object -ComObject Word.Application
$Document = $Word.Documents.Open($DocPath)
$contents = $Document.Paragraphs | ForEach-Object { $_.Range.Text }

$persnumber = ($contents | Select-String -Pattern "Personnel number" -CaseSensitive -Context 0,1).context.postcontext
$badgenumber = ($contents | Select-String -Pattern "Badge number" -CaseSensitive -Context 0,1).context.postcontext
$name = ($contents | Select-String -Pattern "Name" -CaseSensitive -Context 0,1).context.postcontext[0]
$firstname = ($contents | Select-String -Pattern "First name" -CaseSensitive -Context 0,1).context.postcontext
$preferredname = ($contents | Select-String -Pattern "Preferred name" -CaseSensitive -Context 0,1).context.postcontext
$Sameprofile =($contents | Select-String -Pattern "Same profile as" -CaseSensitive -Context 0,1).context.postcontext.trim()


#fix data
$persnumber = $persnumber[0].split()[0]
$badgenumber = $badgenumber[0].split()[0]
$temp = $name.split()| foreach {if ($_ -match "[a-z][A-Z]"){$_}} ; $name = $temp.trim()
$temp = $Firstname.split(" ")| foreach {if ($_ -match "[a-z][A-Z]"){$_}} ; $Firstname = $temp.trim()
$temp = $preferredname.split(" ")| foreach {if ($_ -match "[a-z][A-Z]"){$_}} ; $preferredname = "" ;if($temp){ 0..($temp.length -1) | %{$preferredname += $temp[$_] + " "} ; $preferredname = $preferredname.trim()}
$temp = $sameprofile.split(" ")| foreach {if ($_ -match "[a-z][A-Z]"){$_}} ; $sameprofile = "" ; 0..($temp.count -1) | %{$sameprofile += $temp[$_] + " "} ; $sameprofile = $sameprofile.trim()
#generate script command

$SPA = (get-aduser -filter {name -like $Sameprofile}).samaccountname

if ($preferredname.length -gt 0){
echo "New-RDInternalUser -GivenName `"$preferredname`" -SurName `"$name`" -EmployeeID $persnumber -BadgeID $badgenumber -IdenticalProfile $SPA"
}Else{
echo "New-RDInternalUser -GivenName `"$firstname`" -SurName `"$name`" -EmployeeID $persnumber -BadgeID $badgenumber -IdenticalProfile $SPA"
}
