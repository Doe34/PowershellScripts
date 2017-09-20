#witch dl has to be modified with send as permissions
$dl = Read-Host "Please enter the name of the distribution list"

#get the users from the dl
$user = get-DistributionGroupmember $dl

#add the permissions
foreach ($u in $user){
Get-DistributionGroup $dl| Add-ADPermission -User $u.name -ExtendedRights "Send As"
}

#show the update
Get-DistributionGroup $dl| get-ADPermission | ?{$_.IsInherited -eq $false} | ft -AutoSize