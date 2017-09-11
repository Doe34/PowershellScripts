# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
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
  $install = 'function updateps {iex (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Doe34/PowershellScripts/master/install.ps1")}'
  Add-Content  $pshome\$Profile $install -force
  }
  
  #Look for functions and add dot source these files in the profile


