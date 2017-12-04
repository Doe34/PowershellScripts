# Remove Windows store
if (Get-AppxPackage microsoft.windowsstore) {Get-AppxPackage microsoft.windowsstore | Remove-AppxPackage}                                                                      

# must run Powershell as administrator
# install windows store
$package = (Get-Appxpackage -Allusers microsoft.windowsstore).packagefullname                                                                                                                                                                               
Add-AppxPackage -register "C:\Program Files\WindowsApps\$package\AppxManifest.xml" -DisableDevelopmentMode      