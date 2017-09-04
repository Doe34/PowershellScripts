function Get-AllFunctions
{    #Create an hashtable variable 
    [hashtable]$Return = @{} 

	$Return.scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$Return.rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$scripts = Get-ChildItem -re $Return.rootPath -in *.ps*1 | Where-Object { $_.Name -ne $Return.scriptName }
	foreach ( $item in $scripts ) {
		. $item.FullName
		#write-output $item.FullName
	}

	write-output "All from the found ps*1 files are dot sourced"
	#return $Return

}