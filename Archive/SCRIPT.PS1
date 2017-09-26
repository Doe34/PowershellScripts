
## add servers in the variable
## example:
##
##  $Servers = @(
##  "computer1";
##  "server2";
##  "server3")
##
##

$Servers = @(
"DUMMY")

##
## DO NOT MODIFY
## THE CODE BELOW THIS POINT
##


if (-not $servers) { $Servers = $env:computername }
$output = @()

############## Functions to use - Begin #################
function Get-LocalGroupMembers 
{ 
    param( 
        [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] 
        [Alias("Name")] 
        [string]$ComputerName, 
        [string]$GroupName = "Administrators" 
    ) 

    begin {} 

    process 
    { 
        # If the account name of the computer object was passed in, it will 
        # end with a $. Get rid of it so it doesn't screw up the WMI query. 
        $ComputerName = $ComputerName.Replace("`$", '') 

        # Initialize an array to hold the results of our query. 
        $arr = @() 

        # Get hostname of remote system.  $computername could reference cluster/alias name.  Need real hostname for subsequent WMI query.
        $hostname = (Get-WmiObject -ComputerName $ComputerName -Class Win32_ComputerSystem).Name

        $wmi = Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$Hostname',Name='$GroupName'`"" 

        # Parse out the username from each result and append it to the array. 
        if ($wmi -ne $null) 
        { 
            foreach ($item in $wmi) 
            { 
                $data = $item.PartComponent -split "\,"
                $domain = ($data[0] -split "=")[1]
                $name = ($data[1] -split "=")[1]
                $arr += ("$domain\$name").Replace("""","")
                [Array]::Sort($arr)
            } 
        } 

        $arr
    } 

    end{} 
}

function Get-ADNestedGroupMembers {

    param (
    [Parameter(ValuefromPipeline=$true,mandatory=$true)][String] $GroupName,
    [int] $nesting = -1,
    [int]$circular = $null
    )

    $modules = get-module | select -expand name
    $table = $null
    $nestedmembers = $null
    $adgroupname = $null     
    $nesting++   
    $ADGroupname = get-adgroup $groupname -properties memberof,members
    $memberof = $adgroupname | select -expand memberof
    write-verbose "Checking group: $($adgroupname.name)"
    if ($adgroupname)
    { 
        if ($circular)
        {
            $nestedMembers = Get-ADGroupMember -Identity $GroupName -recursive
            $circular = $null
        }
        else
        {
            $nestedMembers = Get-ADGroupMember -Identity $GroupName | sort objectclass -Descending
            if (!($nestedmembers))
            {
                $unknown = $ADGroupname | select -expand members
                if ($unknown)
                {
                    $nestedmembers=@()
                    foreach ($member in $unknown)
                    {
                        $nestedmembers += get-adobject $member
                    }
                }

            }
        }

        foreach ($nestedmember in $nestedmembers)
        {
            $Props = @{Type=$nestedmember.objectclass;Name=$nestedmember.name;DisplayName="";ParentGroup=$ADgroupname.name;Enabled="";Nesting=$nesting;DN=$nestedmember.distinguishedname;Comment=""}

            if ($nestedmember.objectclass -eq "user")
            {
                $nestedADMember = get-aduser $nestedmember -properties enabled,displayname
                $table = new-object psobject -property $props
                $table.enabled = $nestedadmember.enabled
                $table.name = $nestedadmember.samaccountname
                $table.displayname = $nestedadmember.displayname
                $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment
            }
            elseif ($nestedmember.objectclass -eq "group")
            { 
                $table = new-object psobject -Property $props

                if ($memberof -contains $nestedmember.distinguishedname)
                {
                    $table.comment ="Circular membership"
                    $circular = 1
                }

                $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment
                Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular

            }
            else
            {

                if ($nestedmember)
                {
                    $table = new-object psobject -property $props
                    $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment   
                }
            }

        }
    }
}

function GetGroups
{
  param($strGroup,$strDomain = "")

  $result=@()
  $domain = (Get-ADDomain).name
  if ($strDomain -like $domain)
    {
      $domainoutput = (Get-ADNestedGroupMembers $strGroup)
      foreach($do in $domainoutput.name){$result += $strDomain + "\" + $do}
    }
  elseif($strGroup -like "SYSTEM")
    {return}
  else
    {
      $localoutput = (Get-LocalGroupMembers $strDomain $strGroup)
      foreach($lo in $localoutput)
      {
      $testdomain = $lo.tostring().split("\")[0]
      $testgroup = $lo.tostring().split("\")[1]
        if($testdomain -like $Domain)
            {  if (Get-ADNestedGroupMembers $testgroup)
             {
             $domainoutput = (Get-ADNestedGroupMembers $testgroup)
             foreach($do in $domainoutput.name){$result += $testDomain + "\" + $do}
             }
             else
             {
             $result += $lo
             }
          }
        else
          {$result += $lo}
      }
    }
  foreach($r in $result){$r}
}
############## Functions to use - End #################

$Shares = ""

foreach ($Server in $Servers)
{

  $Shares = Get-WmiObject -Class win32_share -ComputerName $Server | Where-Object { $_.type -eq '0' } | Select-Object -Expand name
  if ($shares) {
    foreach ($Share in $Shares)
    {
      $SharePath = "\\" + $Server + "\" + $Share
      $errorshare = 0

      try
      {
        $Results = Get-Acl -Path $SharePath
      }
      catch
      {
        $props = [ordered]@{
          server = $server
          path = $share
          Owner = "error accessing share"
          Group = "error accessing share"
          AccessControlType = "error accessing share"
          FileSystemRights = "error accessing share"
          IdentityReference = "error accessing share"
          InheritanceFlags = "error accessing share"
          IsInherited = "error accessing share"
          PropagationFlags = "error accessing share"
        }

        $errorshare = 1
        $output += New-Object -TypeName PSObject -Property $Props
      }

      if ($errorshare -eq 0)
      {

        foreach ($access in $results.Access)
        {


          $props = [ordered]@{
            server = $server
            path = $share
            Owner = ($results.Owner)
            Group = ($results.Group)
            AccessControlType = ($access.AccessControlType)
            FileSystemRights = ($access.FileSystemRights)
            IdentityReference = ($access.IdentityReference)
            InheritanceFlags = ($access.InheritanceFlags)
            IsInherited = ($access.IsInherited)
            PropagationFlags = ($access.PropagationFlags)
          }

          $output += New-Object -TypeName PSObject -Property $Props


          $ea = $ErrorActionPreference
          $ErrorActionPreference = "silentlycontinue"
          $group = ""
          $group = $props.IdentityReference.ToString().split("\")[1]
          $Local = $props.IdentityReference.ToString().split("\")[0]


          $groups = if ($group)
          {
            if($local -like "BUILTIN" -or $local -like "NT AUTHORITY" -or $local -like $Server)
            {GetGroups $group $server
            }
            else
            {
            GetGroups $group $Local
            }
          }
          foreach ($g in $groups)
          {
            $props = [ordered]@{
              server = $server
              path = $share
              Owner = ($results.Owner)
              Group = ($results.Group)
              AccessControlType = ($access.AccessControlType)
              FileSystemRights = ($access.FileSystemRights)
              IdentityReference = $g
              InheritanceFlags = ($access.InheritanceFlags)
              IsInherited = ($access.IsInherited)
              PropagationFlags = ($access.PropagationFlags)
            }

            $output += New-Object -TypeName PSObject -Property $Props
          }



          $ErrorActionPreference = $ea

        }

      }

    }
  }
  else
  {
    $props = [ordered]@{
      server = $server
      path = "WARNING:"
      Owner = "no shares found"
      Group = "please check if"
      AccessControlType = "there are shares"
      FileSystemRights = "and you have sufficent"
      IdentityReference = "rights to perform"
      InheritanceFlags = "this operation."
      IsInherited = "-"
      PropagationFlags = "-"
    }

    $errorshare = 1
    $output += New-Object -TypeName PSObject -Property $Props
  }

}

$notmatch = "S-1-5-21-2044444044-1522222311|S-1-5-21-1111012101-3503330338"
$output | ?{$_.IdentityReference -notmatch $notmatch } | Export-Csv "$env:USERPROFILE\desktop\export.csv" -Delimiter ";" -NoTypeInformation
$output | ?{$_.IdentityReference -notmatch $notmatch } | ft











Function Adduserinfo ($username){
$userinfo = @("samaccountname",
              "displayname",
              "mail",
              "title",
              "office",
              "department",
              "company",
              "city",
              "country",
              "extensionattribute10")

foreach ($user in $username) {get-aduser -filter {samaccountname -like $user} -Properties * | select $userinfo}
}

#########################################

$ea = $ErrorActionPreference
$ErrorActionPreference = "silentlycontinue"

$r1 = $output | %{if ($_.IdentityReference.split("\")[0] -like "COMPANY")
{$addinfo = Adduserinfo $_.IdentityReference.split("\")[1]

        $props = [ordered]@{
            server = $_.server
            path = $_.path
            Owner = $_.Owner
            Group = $_.Group
            AccessControlType = $_.AccessControlType
            FileSystemRights = $_.FileSystemRights
          IdentityReference = $_.IdentityReference
          samaccountname = $addinfo.samaccountname
          displayname = $addinfo.displayname
          mail = $addinfo.mail
          title = $addinfo.title
          office = $addinfo.office
          department = $addinfo.department
          company = $addinfo.company
          city =  $addinfo.city
          country =  $addinfo.country
          extensionattribute10 = $addinfo.extensionattribute10
            InheritanceFlags = $_.InheritanceFlags
            IsInherited = $_.IsInherited
            PropagationFlags = $_.PropagationFlags

        }
New-Object -TypeName PSObject -Property $Props
}
else
{        $props = [ordered]@{
            server = $_.server
            path = $_.path
            Owner = $_.Owner
            Group = $_.Group
            AccessControlType = $_.AccessControlType
            FileSystemRights = $_.FileSystemRights
          IdentityReference = $_.IdentityReference
          samaccountname = ""
          displayname = ""
          mail = ""
          title = ""
          office = ""
          department = ""
          company = ""
          city =  ""
          country =  ""
          extensionattribute10 = ""
            InheritanceFlags = $_.InheritanceFlags
            IsInherited = $_.IsInherited
            PropagationFlags = $_.PropagationFlags

        }
New-Object -TypeName PSObject -Property $Props
}
}

$ErrorActionPreference = $ea

$r1 | ?{$_.IdentityReference -notmatch $notmatch } | Export-Csv "$env:USERPROFILE\desktop\exportwithUserinfo.csv" -Delimiter ";" -NoTypeInformation
$r1 | ft




