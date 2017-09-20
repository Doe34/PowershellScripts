$bootTime = (Get-CimInstance win32_Operatingsystem).lastbootuptime
"Boot time is $($bootTime)"
$log = Foreach($log in Get-Eventlog -list)
 {
  Get-EventLog -LogName $log.Log -After $bootTime.AddMinutes(-5) -Before $bootTime.AddMinutes(5) -ea 0
  }
#$log | ?{$_.LevelDisplayName -like "warning" -or $_.LevelDisplayName -like "error"}
$qlog = ($log | select timecreated,logname,leveldisplayname,id,message | ?{$_.LevelDisplayName -like "warning" -or $_.LevelDisplayName -like "error"} | ?{$_.logname -like "system" -or $_.logname -like "application"})
$qlog
