# To enable ANSI sequences in a PowerShell console run the following commands.
# After that you can use wttr.in in you PowerShell just lake that:
#   (curl http://wttr.in/ -UserAgent "curl" ).Content
#
# More on it:
#  http://stknohg.hatenablog.jp/entry/2016/02/22/195644 (jp)
#  

if (-NOT ("Win32.NativeMethods" -as [type])) {
Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int mode);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern IntPtr GetStdHandle(int handle);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool GetConsoleMode(IntPtr handle, out int mode);
"@ -Namespace Win32 -Name NativeMethods
$Handle = [Win32.NativeMethods]::GetStdHandle(-11) #  stdout
$Mode = 0
$Result = [Win32.NativeMethods]::GetConsoleMode($Handle, [ref]$Mode)
$Mode = $Mode -bor 4 # undocumented flag to enable ansi/vt100
$Result = [Win32.NativeMethods]::SetConsoleMode($Handle, $Mode)

chcp 437
}

################
(curl http://wttr.in/Brussel -UserAgent "curl" ).Content