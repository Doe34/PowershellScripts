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
    write-output ('Job #{0} ({1}) complete.' -f $sender.Id, $sender.Name) -ForegroundColor 'DarkGray'
    $jobName | Unregister-Event
    get-job -State Completed | Remove-Job
}
}#Function


#########################
# Window, Path and Help #
#########################
# Set the Path
Set-Location -Path c:
# Refresh Help
$UpdateHelp = Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help -Force } 
write-output "Updating Help in background (Get-Help to check)" -ForegroundColor 'DarkGray'

#Test-job $UpdateHelp

# Show PS Version and date/time
write-output "PowerShell Version: $($psversiontable.psversion) - ExecutionPolicy: $(Get-ExecutionPolicy)" -for yellow

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


#########
# Alias #
#########
Set-Alias -Name npp -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'
Set-Alias -Name np -Value notepad.exe
#if (Test-Path $env:USERPROFILE\OneDrive){$OneDriveRoot = "$env:USERPROFILE\OneDrive"}

#############
# Functions #
#############

<#

# This will change the prompt
function prompt
{
	#Get-location
	Write-output "PS [LazyMe]> "
}
#>

<#

# Get the current script directory
function Get-ScriptDirectory
{
	
	if ($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
	
}
	
	
# DOT Source External Functions
$currentpath = Get-ScriptDirectory
. (Join-Path -Path $currentpath -ChildPath "\functions\Show-Object.ps1")

#>
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

# Learn something today (show a random cmdlet help and "about" article
#Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow
#Get-Random -input (Get-Help about*) | Get-Help -ShowWindow
