$bootTime = (Get-CimInstance win32_Operatingsystem).lastbootuptime
"Boot time is $($bootTime)"
$log = Foreach($log in Get-WinEvent -ListLog *)
 {
  "Events from $($log.Logname) event log"
  Get-WinEvent -LogName $log.Logname -ea 0 |
  where {$_.timecreated -gt $bootTime.AddMinutes(-5) -and $_.timecreated -lt $bootTime.AddMinutes(5)}
  }
