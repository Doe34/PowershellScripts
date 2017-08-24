Function Set-RDExpiration
{

<#
.SYNOPSIS
	This function will set the account expiration date for a user
.DESCRIPTION
	This function will set the account expiration date for a user
	it will also update the discription of the user

.PARAMETER UserName
	Specifies the name or username to query
.PARAMETER Expirationdate
	Specifies the expirationdate of the user
.EXAMPLE
	Set-RDExpiration -UserName User -Expirationdate "31/08/2017"

.EXAMPLE
	Get-AccountLockedOut -UserName "John Doe" -Expirationdate "31/08/2017"
#>

	#Requires -Version 3.0
	[CmdletBinding()]
	param (
    [Parameter(Mandatory=$true)]
    [String]$UserName,
    [Parameter(Mandatory=$true)]
    [String]$Expirationdate

	)
	BEGIN
	{
		TRY
		{
		}#TRY
		CATCH
		{
		}
	}#BEGIN
	PROCESS
	{
		TRY
		{
			if ($UserName -like "* *")
			{
				$user = Get-ADUser -Filter {name -like $UserName } -Properties  description
			}
			else
			{
				$user = Get-ADUser -Filter {SamAccountname -like $UserName } -Properties  description
			}

			$datum = (get-date -date $Expirationdate)
			$addzero = If ($datum.Month -lt 10 ) {"0"}
	    $description = "uit:" + $datum.Year + "/" + $addzero + $datum.Month + "/" + $datum.Day

			$user | Set-ADUser -AccountExpirationDate $datum.AddDays(1)
			$user | Set-ADUser -Description $description

			#Write-host $user
			#write-host $datum.AddDays(1)
			#write-host $description

		}#TRY
		CATCH
		{
		}
	}#PROCESS
}
