    #Create an hashtable variable 
    [hashtable]$Return = @{} 

	$Return.scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$Return.rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$scripts = gci -re $Return.rootPath -in *.ps1 | ?{ $_.Name -ne $Return.scriptName }
	foreach ( $item in $scripts ) {
		. $item.FullName
	}

	#return $Return
	return $scripts