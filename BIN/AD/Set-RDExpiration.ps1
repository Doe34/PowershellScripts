Function Set-RDExpiration
{

<#
.SYNOPSIS
	This function will set the account expiration date for a user
.DESCRIPTION
	This function will set the account expiration date for a user
	it will also update the discription of the user

.PARAMETER Name
	Specifies the name to query (don't use in combination with username)
.PARAMETER UserName
	Specifies the username to query (don't use in combination with name.) !! IF THIS IS USED IT WILL IGNORE NAME !!
.PARAMETER Expirationdate
	Specifies the expirationdate of the user
.EXAMPLE
	Set-RDExpiration -UserName User -Expirationdate "31/08/2017"

.EXAMPLE
	Get-AccountLockedOut -Name "John Doe" -Expirationdate "31/08/2017"
#>

	#Requires -Version 3.0
	[CmdletBinding()]
	param (
		[string]$DomainName = $env:USERDOMAIN,
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$UserName = '*',
		[datetime]$StartTime = (Get-Date).AddDays(-1),
		$Credential = [System.Management.Automation.PSCredential]::Empty


    [Parameter(Mandatory=$true)]
    [String]$aMandatoryParameter,

    [String]$nonMandatoryParameter,

    [Parameter(Mandatory=$true)]
    [String]$anotherMandatoryParameter,

	)
	BEGIN
	{
		TRY
		{
            #Variables
            $TimeDifference = (Get-Date) - $StartTime

			Write-Verbose -Message "[BEGIN] Looking for PDC..."

			function Get-PDCServer
			{
	<#
	.SYNOPSIS
		Retrieve the Domain Controller with the PDC Role in the domain
	#>
				PARAM (
					$Domain = $env:USERDOMAIN,
					$Credential = [System.Management.Automation.PSCredential]::Empty
				)

				IF ($PSBoundParameters['Credential'])
				{

					[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
					(New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList 'Domain', $Domain, $($Credential.UserName), $($Credential.GetNetworkCredential().password))
					).PdcRoleOwner.name
				}#Credentials
				ELSE
				{
					[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
					(New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $Domain))
					).PdcRoleOwner.name
				}
			}#function Get-PDCServer

			Write-Verbose -Message "[BEGIN] PDC is $(Get-PDCServer)"
		}#TRY
		CATCH
		{
			Write-Warning -Message "[BEGIN] Something wrong happened"
			Write-Warning -Message $Error[0]
		}

	}#BEGIN
	PROCESS
	{
		TRY
		{
			# Define the parameters
			$Splatting = @{ }

			# Add the credential to the splatting if specified
			IF ($PSBoundParameters['Credential'])
			{
                Write-Verbose -Message "[PROCESS] Credential Specified"
				$Splatting.Credential = $Credential
				$Splatting.ComputerName = $(Get-PDCServer -Domain $DomainName -Credential $Credential)
			}
			ELSE
			{
				$Splatting.ComputerName =$(Get-PDCServer -Domain $DomainName)
			}

			# Query the PDC
            Write-Verbose -Message "[PROCESS] Querying PDC for LockedOut Account in the last Days:$($TimeDifference.days) Hours: $($TimeDifference.Hours) Minutes: $($TimeDifference.Minutes) Seconds: $($TimeDifference.seconds)"
			Invoke-Command @Splatting -ScriptBlock {

				# Query Security Logs
				Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740; StartTime = $Using:StartTime } |
				Where-Object { $_.Properties[0].Value -like "$Using:UserName" } |
				Select-Object -Property TimeCreated,
							  @{ Label = 'UserName'; Expression = { $_.Properties[0].Value } },
							  @{ Label = 'ClientName'; Expression = { $_.Properties[1].Value } }
			} | Select-Object -Property TimeCreated, UserName, ClientName
		}#TRY
		CATCH
		{

		}
	}#PROCESS
}
