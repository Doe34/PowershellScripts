#requires -version 2.0

Function New-Timer {

<#
.Synopsis
Create an event timer object
.Description
Create an event timer object, primarily to be used by the ConsoleTitle module.
Each timer job will automatically be added to the global variable, $ConsoleTitleEvents
unless you use the -NoAdd parameter. This variable is used by Remove-Timer to clear
console title related timers.

This function is called from within other module functions but you can use it to
create non-module timers.

.Parameter Identifier
A source identifier for your timer
.Parameter Refresh
The timer interval in Seconds. The default is 300 (5 minutes). Minimum
value is 5 seconds.
.Parameter Action
The scriptblock to execute when the timer runs down.
.Parameter NoAdd
Don't add the timer object to the $ConsoleTitleEvents global variable.
#>

Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a source identifier for your timer")]
[ValidateNotNullorEmpty()]
[string]$Identifier,
[Parameter(Position=1)]
[validatescript({$_ -ge 5})]
[int]$Refresh=300,
[Parameter(Position=2,Mandatory=$True,HelpMessage="Enter an action scriptblock")]
[scriptblock]$Action,
[switch]$NoAdd
)

Write-Verbose ("Creating a timer called {0} to refresh every {1} seconds." -f $Identifier,$Refresh)

#create a timer object
$timer = new-object timers.timer
#timer interval is in milliseconds
$timer.Interval = $Refresh*1000
$timer.Enabled=$True

#create the event subscription and add to the global variable
$evt=Register-ObjectEvent -InputObject $timer -EventName elapsed –SourceIdentifier $Identifier -Action $Action

if (-Not $NoAdd) {
#add the event to a global variable to track all events
$global:ConsoleTitleEvents+=$evt
}
#start the timer
$timer.Start()

} #Function

Function Set-TimerInterval {

<#
.Synopsis
Set a new timer refresh interval
.Description
This function will change the interval property of your event timers. You can
either specify a single event subscriber name or use -All to update all timers
to the same value. The refresh interval is in seconds with a minumum value of
5.
.Parameter SourceIdentifier
A source identifier for your timer
.Parameter Refresh
The new timer interval in seconds. Minimum value is 5
.Parameter All
Update all consoletimer event subscribers to the same value
#>

[cmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName="default")]

Param (
[Parameter(Position=0,HelpMessage="Enter the sourceidentifier of an event subscriber",ParameterSetName="Default")]
[string]$SourceIdentifier,
[Parameter(Mandatory=$True,HelpMessage="Enter the new refresh interval in seconds")]
[ValidateScript({$_ -ge 5})]
[int]$Refresh,
[Parameter(ParameterSetName="All")]
[switch]$All
)

if ($all) {
$sourceIdentifier=$global:ConsoleTitleEvents | Where {$_.state -eq "Running"} | Select-Object -ExpandProperty Name -Unique
}

if (-Not $SourceIdentifier) {
Write-Error "No value specified for SourceIdentifier"
}
else {
$sourceidentifier | foreach {
Get-EventSubscriber -SourceIdentifier $_ | ForEach {
Write-Verbose $_.SourceIdentifier
if ($psCmdlet.ShouldProcess("$($_.SourceIdentifier) to $Refresh")) {
$_.sourceobject.Interval=($Refresh*1000)
} #should process
} #foreach event subscriber
} #foreach source id
}

} #function

Function Get-Timer {

<#
.Synopsis
Get console timer objects
.Description
Get all event subscribers created for updating the console window title.
#>

Param()

if ($global:ConsoleTitleEvents) {
$global:ConsoleTitleEvents | Where {$_.state -match "Running|NotStarted"} | select name -unique | foreach {
get-eventsubscriber -source $_.name | Select SourceIdentifier,@{Name="Refresh";Expression={
$_.SourceObject.Interval/1000}}, @{Name="Enabled";Expression={$_.SourceObject.Enabled}},
@{Name="Action";Expression={$_.Action.Command}}
}
}

} #function

Function Remove-Timer {

<#
.Synopsis
Remove timer event subscriptions
.Description
This function will remove all console title related timer event subscriptions.
.Parameter Events
The events to remove. This defaults to the global variable $ConsoleTitleEvents

#>

[cmdletBinding(SupportsShouldProcess=$True)]

Param(
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
$Events=$global:ConsoleTitleEvents)

if ($events -is [string]) {
Get-EventSubscriber -SourceIdentifier $events | foreach {
$_ | Unregister-Event
get-job -Name $_.SourceIdentifier | Remove-Job
}
}
else {
#there might be old and new events for the same name, so just get the names
$events | Select -Property Name -Unique | foreach { Get-EventSubscriber -SourceIdentifier $_.name} |
foreach {

$_| Unregister-Event
get-job -Name $_.SourceIdentifier | Remove-Job
}

}
} #Function

Function Start-TitleTimer {

<#
.Synopsis
Create a timer to update the console window title
.Description
This function will update the console window title and create a new event
timer that will update the title at the end of the refresh period. This event
will continue until you remove it or end your PowerShell session.
.Parameter Title
The text to set for the console window title. The default is the value of the
global variable $PSConsoleTitle
.Parameter Refresh
The timer interval in Seconds. The default is 300 (5 minutes). Minimum
value is 5 seconds.
#>

Param(
[Parameter(Position=0)]
[string]$Title=$global:PSConsoleTitle,
[Parameter(Position=1)]
[ValidateScript({$_ -ge 5})]
[int]$Refresh=300
)

Write-Verbose "Creating timer event to update console title every $Refresh seconds"
#create a timer action
$Actionsb= {$host.ui.RawUI.WindowTitle=$Global:PSConsoleTitle}

#invoke the scriptblock to set the title now
Write-Verbose ("{0} Setting window title to {1}. " -f (Get-Date),$Global:PSConsoleTitle)
Invoke-Command -ScriptBlock $ActionSB

#create a timer object
New-Timer -Identifier "TitleTimer" -Refresh $Refresh -Action $ActionSB

} #function

Function Get-SystemStat {

<#
.Synopsis
Set console window title with system information
.Description
This is a sample command to update the console title bar with system
information gathered from WMI. This is a sample:

CLIENT01 CPU:18% FreeMem:931MB Procs:118 Free C:10.57% ?5.05:23:22

The function will create the necessary background timer.
.Parameter Refresh
The timer interval in Seconds. The default is 300 (5 minutes). Minimum
value is 5 seconds.

#>

Param(
[Parameter(Position=0)]
[ValidateScript({$_ -ge 5})]
[int]$Refresh=300
)

#create a scriptblock
$sb={
#Gather some stats
$cdrive=Get-WMIObject -query "Select Freespace,Size from win32_logicaldisk where deviceid='c:'"
[int]$freeMem=(Get-Wmiobject -query "Select FreeAndZeroPageListBytes from Win32_PerfFormattedData_PerfOS_Memory").FreeAndZeroPageListBytes/1mb
$cpu=Get-WMIObject -class win32_processor -Property loadpercentage
$pcount=(Get-Process).Count
$diskinfo="{0:N2}" -f (($cdrive.freespace/1gb)/($cdrive.size/1gb)*100)
#get uptime
$OS=Get-WmiObject -class Win32_OperatingSystem
$Uptime=(Get-Date) - $OS.ConvertToDateTime($OS.Lastbootuptime)
#parse out milliseconds from uptime
$up=$uptime.tostring().Substring(0,$uptime.ToString().LastIndexOf("."))
[string]$text="{5} CPU:{0}% FreeMem:{6}MB Procs:{1} Free C:{2}% {3}{4}" -f $cpu.LoadPercentage,$pcount,$diskinfo,([char]0x25b2),$up,$env:computername,$FreeMem

Write-verbose $text
$global:PSConsoleTitle=$Text
}

Write-Verbose "Creating timer event to get system stats every $refresh seconds"

#invoke the scriptblock to set the title now
Invoke-Command -ScriptBlock $sb

New-Timer -identifier "SystemStatTimer" -action $sb -refresh $refresh

} #end Function

Function Set-ConsoleTitle {

<#
.Synopsis
Set the console window title
.Description
This function immediately sets the console window title bar. The
default value is $PSConsoleTitle.
.Parameter Title
The new value for the console window title bar.

#>

[cmdletbinding(SupportsShouldProcess=$True)]

Param(
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
[string]$Title=$global:PSConsoleTitle
)

if ($pscmdlet.shouldprocess($Title)) {
$host.ui.RawUI.WindowTitle=$Title
}

} #function

Function Get-Ticker{
$host.ui.RawUI.WindowTitle
}

Function Start-Ticker {

<#
.Synopsis
Set console window title with a quote or message
.Description
This is a sample command to update the console title bar with a random
powershell cmdlet and its definition taken from an array of strings, stored in the global
variably $cmdletdef. This array is pre-defined but you can modife the value
of $cmdletdef from your PowerShell session anytime you want.

If there is no title timer object, this command will create it.

.Parameter Refresh
The timer interval in seconds. The default is 300 (5 minutes). Minimum
value is 5 seconds.

#>

Param(
[Parameter(Position=0)]
[ValidateScript({$_ -ge 5})]
[int]$Refresh=300
)


$sb={ 
$user = "hln_Be"
$timeline = get-tweettimeline -Username $user
$news = ($timeline | select in_reply_to_screen_name,text -first 1 | where in_reply_to_screen_name -like "").text
$global:cmdletdef=$news
$global:PSConsoleTitle=$global:cmdletdef }

Invoke-Command $sb

New-Timer -identifier "SloganUpdate" -action $sb -refresh $refresh

#start the update timer if not already running
if (-Not (Get-EventSubscriber -SourceIdentifier "TitleTimer" -ea "SilentlyContinue")) {
Start-TitleTimer -refresh $refresh
}

} #function

#=================================================================

#Set a global variable for the console title
$Global:PSConsoleTitle="PowerShell Windows 2.0"
$Global:ConsoleTitleEvents=@()

Export-ModuleMember -Function * -Variable PSConsoleTitle,cmdletdef,ConsoleTitleEvents