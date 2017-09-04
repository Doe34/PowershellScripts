#bring application back into focus
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Tricks {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
"@

$clipboard = get-clipboard
$url = "https://mysites.realdolmen.com/personal/" + $env:username + "/Documents/Forms/All.aspx"
set-clipboard $url
add-type -AssemblyName microsoft.VisualBasic
add-type -AssemblyName System.Windows.Forms

& (gci -filter "groove" -Path ${env:ProgramFiles(x86)} -Recurse -ErrorAction SilentlyContinue).fullname

$i
do {
try{
[Microsoft.VisualBasic.Interaction]::AppActivate("Microsoft OneDrive for Business")
break
}
catch
{
sleep -m 1000
$i++
	if($i -gt 5 ) {
	[System.Windows.Forms.MessageBox]::Show("Cannot start OneDrive for Business. Please contact Helpdesk","Allready configured or not found",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
	return
	}
}
}while($true)


$h = (Get-Process groove).MainWindowHandle
[void] [Tricks]::SetForegroundWindow($h)

[System.Windows.Forms.SendKeys]::SendWait("^v")
[System.Windows.Forms.SendKeys]::SendWait("`n")
set-clipboard $clipboard
