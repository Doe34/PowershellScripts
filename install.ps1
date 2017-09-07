#what is my destination?
$Destinationpath="c:\PowershellScripts"

if (!(Test-Path $Destinationpath)) {
    $null = mkdir $Destinationpath
}


#Copy me from github
$temp = $env:TEMP
Invoke-WebRequest -Uri "https://github.com/Doe34/PowershellScripts/archive/master.zip" -OutFile "$temp\install.zip"

Expand-ZipFile -Path "$temp\install.zip" -DestinationPath $Destinationpath

robocopy $Destinationpath\PowershellScripts-master $Destinationpath\ /e /mov

Remove-Item $Destinationpath\PowershellScripts-master -recurse


#what is the profile name?
$Profile = "Microsoft.PowerShell_profile.ps1"


#Modify profile


  #Add Destinationpath to the env:path veriable in the profile
  

  #add install.ps1 to profile so it updates itself


  #Look for functions and add dot source these files in the profile


