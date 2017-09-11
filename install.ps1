# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}
##############################################################################


#what is my destination?
$Destinationpath="c:\PowershellScripts"

if (!(Test-Path $Destinationpath)) {
    $null = mkdir $Destinationpath
}


#Copy me from github
$temp = $env:TEMP
Invoke-WebRequest -Uri "https://github.com/Doe34/PowershellScripts/archive/master.zip" -OutFile "$temp\install.zip"

Expand-ZipFile -Path "$temp\install.zip" -DestinationPath $Destinationpath

remove-item $Destinationpath\install.ps1

robocopy $Destinationpath\PowershellScripts-master $Destinationpath\ /e /mov

Remove-Item $Destinationpath\PowershellScripts-master -recurse


#what is the profile name?
$Profile = "Microsoft.PowerShell_profile.ps1"

#Modify profile

  move-item $Destinationpath\$Profile $pshome\$Profile -force -confirm:$false
  
  #Add Destinationpath to the env:path veriable in the profile
  
  $path  = '$Destinationpath="c:\PowershellScripts"
            $env:Path += ";" + $Destinationpath'
  if(-not (get-content $pshome\$Profile | Select-String -Pattern "Destinationpath")){
  Add-Content  $pshome\$Profile $path -force
 
  #add install.ps1 so it updates itself
  $install = 'function updateps {iex (New-Object Net.WebClient).DownloadString(''https://raw.githubusercontent.com/Doe34/PowershellScripts/master/install.ps1'')}'
  Add-Content  $pshome\$Profile $install -force
  }
  
  #Look for functions and add dot source these files in the profile


