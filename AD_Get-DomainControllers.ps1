Function Get-DomainControllers
{
[CmdletBinding()]
param()
<#
	.SYNOPSIS

	Find all domain controllers in domain
	
	.DESCRIPTION
	
	Uses methode 3 to retreive the domain controllers
		
	.SYNTAX
	
	Get-Get-DomainControllers
	
	.EXAMPLE
		PS C:\> Get-Get-DomainControllers
	
	.NOTES
	
	Find all domain controllers in domain
	
	https://use-powershell.blogspot.be/2013/04/find-all-domain-controllers-in-domain.html
	
	Using powershell one can find all domain controllers in domain using:

	1. a LDAP filter:

		Get-ADComputer -LDAPFilter "(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))"


	2. "Domain controllers" group and retreive his memebers:

		Get-ADGroupMember 'Domain Controllers'


	3. Get-ADDomainController cmdlet:

		Get-ADDomainController -Filter * | Select-Object name
#>

	BEGIN
	{
		# GlobalVariables
		
		# Helper function for Default Verbose/Debug message
		function Get-DefaultMessage
		{
			param ($Message)
			Write-Output "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss:ff')][$((Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name)] $Message"
		}#Get-DefaultMessage
		
		# Handlers
		
	}#BEGIN
	PROCESS
	{
		Get-ADDomainController -Filter * | Select-Object name
	}#PROCESS
	END
	{
		Write-Verbose -Message (Get-DefaultMessage -Message "Script Completed")
	}#END
}#Function