Function Get-Sam {
param(
  [parameter(Position=0,Mandatory=$false,ParameterSetName="Username",ValueFromPipeline=$true)]
    [String] $User
)
Try
{
$length = (get-aduser -filter {name -like $user} -Properties canonicalname).CanonicalName.indexof("/")
$domain = (get-aduser -filter {name -like $user} -Properties canonicalname).CanonicalName.substring(0,$length)
$Samaccountname = (get-aduser -filter {name -like $user} -Properties canonicalname).samaccountname
$samaccount = $domain + "\" + $Samaccountname 
return $samaccount
}
Catch
{
Write-host "-- Username not found --" -ForegroundColor Red
}
}