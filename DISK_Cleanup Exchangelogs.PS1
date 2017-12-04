$days=180
#$Targetfolder = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\"
$Targetfolder = "D:\Exchange Server\Logging\"

write-host -debug -ForegroundColor Yellow -BackgroundColor Cyan $TargetFolder

  if (Test-Path $TargetFolder) {
      $Now = Get-Date
      $LastWrite = $Now.AddDays(-$days)
      $Files = Get-ChildItem $Targetfolder  -Recurse | Where-Object {$_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName  
      foreach ($File in $Files)
          {
             $FullFileName = $File.FullName  
             Write-Host "Deleting file $FullFileName" -ForegroundColor "yellow"; 
              Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
          }
     }
Else {
    Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
    }
