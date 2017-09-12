$OmnitrackerJob = Start-Job -Name "Omnitracker" -ScriptBlock  {
	while($true)
	{
		$Omnitracker = get-process "*omnitracker*" -ErrorAction SilentlyContinue
		
		if(-not$Omnitracker){
			Try
			{
			add-type -AssemblyName microsoft.VisualBasic
			add-type -AssemblyName System.Windows.Forms
			start-sleep -Milliseconds 500

			start-process "C:\Program Files (x86)\OMNITRACKER\OMNINET.OMNITRACKER.Client.exe"
			start-sleep -Milliseconds 500
			[Microsoft.VisualBasic.Interaction]::AppActivate("OMNITRACKER")
			start-sleep -Milliseconds 1000
			[System.Windows.Forms.SendKeys]::SendWait("{enter}")
			sleep 1
			}
			catch
			{
			}
		}
		
		if($Omnitracker){sleep 10}
	}
}