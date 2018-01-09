#script written by Raja

# for get user Account Lockout Host name

$username = Read-Host "Please Enter the Locked User Name: "
 
        $DCCounter = 0  
        $LockedOutStats = @()    
                 
        Try 
        { 
            Import-Module ActiveDirectory -ErrorAction Stop 
        } 
        Catch 
        { 
           Write-Warning $_ 
           Break 
        } 
         
        #Get all domain controllers in domain 
        $DomainControllers = Get-ADDomainController -Filter * 
        $PDCEmulator = ($DomainControllers | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"}) 
         
        Write-Verbose "Finding the domain controllers in the domain" 
        Foreach($DC in $DomainControllers) 
        { 
            # $DCCounter++ 
            # Write-Progress -Activity "Contacting DCs for lockout info" -Status "Querying $($DC.Hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100) 
	    Write-Verbose "Finding the Which domain controllers Authenticate the Password"
            Try 
            { 
                $UserInfo = Get-ADUser -Identity $username  -Server $DC.Hostname -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut -ErrorAction Stop 
	    Write-Verbose "Bad Password Attempt count collected"
            } 
            Catch 
            { 
                # Write-Warning $_ 
                Continue 
            } 
            If($UserInfo.LastBadPasswordAttempt) 
            {     
                $LockedOutStats += New-Object -TypeName PSObject -Property @{ 
                        Name                   = $UserInfo.SamAccountName 
                        SID                    = $UserInfo.SID.Value 
                        LockedOut              = $UserInfo.LockedOut 
                        BadPwdCount            = $UserInfo.BadPwdCount 
                        BadPasswordTime        = $UserInfo.BadPasswordTime             
                        DomainController       = $DC.Hostname 
                        AccountLockoutTime     = $UserInfo.AccountLockoutTime 
                        LastBadPasswordAttempt = ($UserInfo.LastBadPasswordAttempt).ToLocalTime() 
                    }           
            }#end if 
        }#end foreach DCs 
        $LockedOutStats | Format-Table -Property Name,LockedOut,DomainController,BadPwdCount,AccountLockoutTime,LastBadPasswordAttempt -AutoSize 
 
        #Get User Info 
        Try 
        {   
           Write-Verbose "Querying event log on $($PDCEmulator.HostName)" 
	   Write-Verbose "Collecting Event Log"
           $LockedOutEvents = Get-WinEvent -ComputerName $PDCEmulator.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending 
        } 
        Catch  
        {           
           Write-Warning $_ 
           Continue 
        }#end catch      
                                  
        Foreach($Event in $LockedOutEvents) 
        {             
           If($Event | Where {$_.Properties[2].value -match $UserInfo.SID.Value}) 
           {  
               
              $Event | Select-Object -Property @( 
                @{Label = 'User';               Expression = {$_.Properties[0].Value}} 
                @{Label = 'DomainController';   Expression = {$_.MachineName}} 
		@{Label = 'EventId';            Expression = {$_.Id}} 
                @{Label = 'LockedOutTimeStamp'; Expression = {$_.TimeCreated}} 
                @{Label = 'Message';            Expression = {$_.Message -split "`r" | Select -First 1}} 
                @{Label = 'LockedOutLocation';  Expression = {$_.Properties[1].Value}}
             ) 
			Write-host $_.MachineName
                                                 
            }#end ifevent 
             
       }#end foreach lockedout event
	Write-Verbose "Collected Details Update in the Text File. Please find the Text file for More Details"

echo "Cache Profile Removal Steps
1) Open Control Panel > Credential Manager > Remove all Saved Password.
2) Remove passwords by clicking on Start => Run => type (rundll32.exe keymgr.dll KRShowKeyMgr) without quotes and then delete the Domain-related passwords;
3) Remove passwords in Internet Explorer => Tools => Internet Options =>Content => Personal Information => Auto Complete => Clear Passwords;
4) Delete cookies in Internet Explorer => Tools => Internet Options =>General;
5) Disconnect (note the path before disconnecting) all networks drives, reboot, then map them again;
6) Start -> run ->type control userpasswords2 without quotes and go to advanced -> Manage passwords and remove all the stored passwords.
7) Reconfigure Your mobile Setting if your Active sync enabled.
8) Check if any saved or scheduled task is configured for user account

Microsoft Kwoledge Bytes Link for Cache profile Removal Steps:

https://social.technet.microsoft.com/Forums/windows/en-US/ced8eab6-87e2-4d20-9d18-7aaf5e9713a3/windows-7-clear-cached-credentials"

    