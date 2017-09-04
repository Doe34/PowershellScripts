function Get-AllPs1
{    #Create an hashtable variable 
    [hashtable]$Return = @{} 

	$Return.scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$Return.rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$scripts = Get-ChildItem -re $Return.rootPath -in *.ps1 | Where-Object { $_.Name -ne $Return.scriptName }
	<#
    foreach ( $item in $scripts ) {
		. $item.FullName
		#write-output $item.FullName
	}

    #>
	return $scripts

}