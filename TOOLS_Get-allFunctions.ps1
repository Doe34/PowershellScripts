function Get-AllFunctions
{    #Create an hashtable variable 
    [hashtable]$Return = @{} 

	$Return.scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$Return.rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$scripts = gci -re $Return.rootPath -in *.ps1 | ?{ $_.Name -ne $Return.scriptName }
	foreach ( $item in $scripts ) {
		. $item.FullName
		#write-host $item.FullName
	}

	Write-host "All from the found ps1 files are dot sourced"
	#return $Return

}