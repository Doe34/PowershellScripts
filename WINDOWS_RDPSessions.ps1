Function Get-RDPSession
{
<#
.SYNOPSYS
Queries a local or remote computer for existing RDPSessions
 
.DESCRIPTION
Uses Qwintsa to query local or remote computers for existing RDP Sessions, reutrns a custom PSObject and can be used in conjuction with Remove-RDPSession
 
.EXAMPLE
Get-RDPSession -ComputerName TESTVM

Returns information about existing sessions on TESTVM:

SESSIONNAME  : services
USERNAME     : 
ID           : 0
STATE        : Disc
TYPE         : 
DEVICE       : 
ComputerName : TESTVM

SESSIONNAME  : console
USERNAME     : 
ID           : 1
STATE        : Conn
TYPE         : 
DEVICE       : 
ComputerName : TESTVM

SESSIONNAME  : rdp-tcp#0
USERNAME     : Jason
ID           : 2
STATE        : Active
TYPE         : 
DEVICE       : 
ComputerName : TESTVM

SESSIONNAME  : rdp-tcp
USERNAME     : 
ID           : 65536
STATE        : Listen
TYPE         : 
DEVICE       : 
ComputerName : TESTVM

.EXAMPLE
Get-RDPSession -ComputerName TESTVM | where {$_.username -like 'Jason'} | Remove-RDPSession

Finds the session for the user named 'Jason', and closes it.

.NOTES
Requires PowerShell Version 3
#>
[cmdletBinding()]
Param 
    (
        [Parameter(
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True)]
        [String[]]$Name = "$env:COMPUTERNAME"
    )
Begin {}
Process 
    {
        $Results = qwinsta /Server:$Name
        $Props = ($Results[0].Trim(" ") -replace ("\b *\B")).Split(" ")
        $Sessions = $Results[1..$($Results.Count -1)]
        Foreach ($Session in $Sessions)
            {
                $hash = [ordered]@{
                        $Props[0] = $Session.Substring(1,18).Trim()
                        $Props[1] = $Session.Substring(19,22).Trim()
                        $Props[2] = $Session.Substring(41,7).Trim()
                        $Props[3] = $Session.Substring(48,8).Trim()
                        $Props[4] = $Session.Substring(56,12).Trim()
                        $Props[5] = $Session.Substring(68,8).Trim()
                        'ComputerName' = "$Name"
                    }
                New-Object -TypeName PSObject -Property $hash 
            }
    }
End {}
}

Function Remove-RDPSession
{
<#
.SYNOPSYS
Removes an existing RDP session on a remote workstation
 
.DESCRIPTION
Uses Rwinsta to remove a remote session by ID number, accepts input from Get-RDPSession or through parameters
 
.EXAMPLE
Remove-RDPSession -Computername TESTVM -ID 2

Removes the session 2 from TESTVM

.EXAMPLE
Get-RDPSession -ComputerName TESTVM | where {$_.username -like 'Jason'} | Remove-RDPSession

Finds the session for the user named 'Jason', and closes it.
 
.NOTES
Requires PowerShell Version 3
#>
[cmdletBinding()]
Param 
    (
        [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$True
        )]
        [String]$Name,
        [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$True
        )]
        [int]$ID
    )
Begin {}
Process 
    {
        rwinsta /Server:$Name $ID
    }
End {}
}
