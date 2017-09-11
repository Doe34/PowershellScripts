<#	
	.SYNOPSIS
		Profile File
	.DESCRIPTION
		Profile File
#>


#############
# functions #
#############

function Test-job
{
param (
    [Parameter(Mandatory=$true)]
    $jobName
	)
$job = Register-ObjectEvent $jobName StateChanged -Action {
    write-host ('Job #{0} ({1}) complete.' -f $sender.Id, $sender.Name) -ForegroundColor 'DarkGray'
    $jobName | Unregister-Event
    get-job -State Completed | Remove-Job
}
}#Function


#########################
# Window, Path and Help #
#########################

# Show PS Version and date/time
write-host "PowerShell Version: $($psversiontable.psversion) - ExecutionPolicy: $(Get-ExecutionPolicy)" -for yellow

$env:Path += ";" + [environment]::getfolderpath("mydocuments") + "\github\powershellscripts"

# Set the Path
Set-Location -Path c:
# Refresh Help
$UpdateHelp = Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help -Force } 
write-host "Updating Help in background (Get-Help to check)" -ForegroundColor 'DarkGray'

#Test-job $UpdateHelp

<#
# Check Admin Elevation
$WindowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
$Administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $WindowsPrincipal.IsInRole($Administrator)

# Custom Window
#  Set Window Title
if ($isAdmin)
{
	$host.UI.RawUI.WindowTitle = "Administrator: $ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
}
else
{
	$host.UI.RawUI.WindowTitle = "$ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
}
#>

###############
# Credentials #
###############



##########
# Module #
##########

import-module -name Ticker

#########
# Alias #
#########
Set-Alias -Name np -Value notepad.exe
Set-Alias -Name npp -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'
Set-Alias -Name ever -Value 'C:\Program Files (x86)\Evernote\Evernote\Evernote.exe'
Set-Alias -Name evernote -Value 'C:\Program Files (x86)\Evernote\Evernote\Evernote.exe'
#if (Test-Path $env:USERPROFILE\OneDrive){$OneDriveRoot = "$env:USERPROFILE\OneDrive"}

#############
# Functions #
#############

<#
 $ImportScripts = Start-Job -Name "ImportScripts" -ScriptBlock { 

	$ErrorActionPreference = "SilentlyContinue"
	$scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$IniFiles = Get-ChildItem -re (Join-Path -Path $rootPath -ChildPath "\INI\") -in *.ini
			
	foreach ( $item in $IniFiles ) {
		if($item.Name -eq "ignore.ini") {$ignore = $item.FullName }
		if($item.Name -eq "passwords.ini") {$passwords = $item.FullName }
	}
	
	$ignorefiles = read-file $ignore
	
	$scripts = Get-ChildItem -re $rootPath -in *.ps1 -exclude $ignorefiles | Where-Object { $_.Name -ne $scriptName }
	
	foreach ( $item in $scripts ) {
		. $item.FullName
		#write-output $item.FullName
	}
	$ErrorActionPreference = "Continue"
 } 
write-output "Importing scripts in background" -ForegroundColor 'DarkGray'   
#>	
#Test-job $ImportScripts

#########
# Other #
#########

start-ticker

#########

if ($env:computername -match "2169"){ . TOOLS_Start-Omnitracker.ps1 }

#########

$cleanup = Start-Job -Name "cleanup" -ScriptBlock { . TOOLS_Cleanup.ps1 } 
write-host "cleaning temp files" -ForegroundColor 'DarkGray'

#########


$ErrorActionPreference = "stop"
Try {
 $key = "HKcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\"
 $download = (Get-ItemProperty -Path $key -name "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}").'{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}'
}
Catch [System.Management.Automation.PSArgumentException]
 {
 $download = $env:homedrive + $env:homepath + "\downloads"
 }
Catch [System.Management.Automation.ItemNotFoundException]
 {
 $download = $env:homedrive + $env:homepath + "\downloads"
 }
Finally { $ErrorActionPreference = "Continue" }



#########

            #Get KnownFolder Paths
            $appdata=$env:appdata
            $Cookies=(new-object -com shell.application).namespace(289).Self.Path
            $History=(new-object -com shell.application).namespace(34).Self.Path
            $recent=(new-object -com shell.application).namespace(8).Self.Path
            $profile=$env:userprofile

$CleanItembyage = Start-Job -Name "CleanItembyage" -ScriptBlock { 
            #commands
            #remove-itembyage -days 0 -path $appdata -typefilter "txt,log" -silent -whatif
            remove-itembyage -days 90 -path $cookies -silent 
            remove-itembyage -days 14 -path $recent -silent 
            remove-itembyage -days 21 -path $history -silent 
            remove-itembyage -days 14 -path "$appdata\Microsoft\office\Recent" -silent 
 } 
write-host "cleaning temp items by age" -ForegroundColor 'DarkGray'


#########


if (-NOT ("Win32.NativeMethods" -as [type])) {
Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int mode);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern IntPtr GetStdHandle(int handle);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool GetConsoleMode(IntPtr handle, out int mode);
"@ -Namespace Win32 -Name NativeMethods
$Handle = [Win32.NativeMethods]::GetStdHandle(-11) #  stdout
$Mode = 0
$Result = [Win32.NativeMethods]::GetConsoleMode($Handle, [ref]$Mode)
$Mode = $Mode -bor 4 # undocumented flag to enable ansi/vt100
$Result = [Win32.NativeMethods]::SetConsoleMode($Handle, $Mode)

#chcp 437
}

# show me the wheater in brussel
(curl http://wttr.in/brussel?0 -UserAgent "curl" ).Content
