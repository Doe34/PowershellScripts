function DirWithSize($path=$pwd)
{   $fso = New-Object -com  Scripting.FileSystemObject
    Get-ChildItem -recurse -force  -ErrorAction silentlycontinue -path $path |select Mode, LastWriteTime, fullName,
        @{ Label="Length";
           Expression={
              if($_.PSIsContainer){$fso.GetFolder( $_.FullName).Size}
              else {$_.Length}
           }
         }
}
