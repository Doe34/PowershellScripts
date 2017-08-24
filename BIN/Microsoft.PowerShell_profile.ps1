<#	
	.SYNOPSIS
		Profile File
	.DESCRIPTION
		Profile File
#>

#########################
# Window, Path and Help #
#########################
# Set the Path
Set-Location -Path c:
# Refresh Help
Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help -Force } | Out-null
Write-Host "Updating Help in background (Get-Help to check)" -ForegroundColor 'DarkGray'
# Show PS Version and date/time
Write-host "PowerShell Version: $($psversiontable.psversion) - ExecutionPolicy: $(Get-ExecutionPolicy)" -for yellow

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
#  PSReadLine
#Import-Module -Name PSReadline

#Import modules
Start-Job -Name "UpdateHelp" -ScriptBlock {get-module -ListAvailable | Import-module } | Out-null
Write-Host "Importing all modules" -ForegroundColor 'DarkGray'

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
    
	$ErrorActionPreference = "SilentlyContinue"
	$scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$IniFiles = gci -re (Join-Path -Path $rootPath -ChildPath "\INI\") -in *.ini
	$scripts = gci -re $rootPath -in *.ps1 | ?{ $_.Name -ne $scriptName }
	
	#read-file *.ini
	
	foreach ( $item in $scripts ) {
		. $item.FullName
		#write-host $item.FullName
	}
	$ErrorActionPreference = "Continue"
	
#########
# Other #
#########

# Learn something today (show a random cmdlet help and "about" article
#Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow
#Get-Random -input (Get-Help about*) | Get-Help -ShowWindow