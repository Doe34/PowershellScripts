Function Cleanup-UserProfiles
<#
.Parameter ComputerName
The computer on which to clean profiles.

.Parameter AgeLimit
All profiles older than this number of days will be removed

.Parameter Exclude
Comma separt
#>
{
  [CmdletBinding(
     SupportsShouldProcess=$true,
    ConfirmImpact="High"
  )]param ($computerName= '.',$AgeLimit='60', $Exclude)

  $dateLimit = (get-date).adddays(-1 * $agelimit)
  $userprofiles = Get-WmiObject -Class Win32_UserProfile -ComputerName $computerName

  #the default exclusion list will prevent deletion of Administrator acount, Default accounts, System and Network Service
  $exclusionlist = @('S-1-5-19','S-1-5-18','S-1-5-20','-500$') + $Exclude | where-object {$_}

  foreach ($profile in $userprofiles) {
    #Check if profile is in date range
    $dateLastUsed = [datetime]::ParseExact(($profile.lastusetime -replace '\..+$',''),'yyyyMMddHHmmss',$null )
    if ( $dateLastused -ge $dateLimit){
        write-verbose "Skipping $($profile.sid) because it was last used $dateLastUsed"
        continue;    
    }

    #Check if profile matches an exclusion
    $MatchesExclusion = $false
    foreach ($comparison in $exclusionlist){
        if ($profile.sid -match $comparison -or $profile.localpath -match $comparison)
        {
            $MatchesExclusion = $true
            write-verbose "Skipping $($profile.sid) because it matches exclusion '$comparison'"
            break;
        }
    }
    if ($MatchesExclusion) {continue;}
    
    #Use ShouldProcess to prevent accidental removal of profiles
    $activity = "Remove profile for user $($profile.SID) from computer $Computername with local path $($profile.localpath)"
    if ($pscmdlet.ShouldProcess($activity)) {
        Write-Verbose "Attempting to $activity"
        $profile.Delete()       
    }
  }
}