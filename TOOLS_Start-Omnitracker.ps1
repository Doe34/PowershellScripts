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
			do {
			start-sleep -Milliseconds 500
			} while (-not (Get-Process OMNINET.OMNITRACKER.Client | Where-Object {$_.mainWindowTitle -match "OMNITRACKER - Login"}) )
			[Microsoft.VisualBasic.Interaction]::AppActivate("OMNITRACKER")
			start-sleep -Milliseconds 500
			[System.Windows.Forms.SendKeys]::SendWait("{enter}")
			}
			catch
			{
			}
		}
		
		if($Omnitracker){sleep 10}
	}
}