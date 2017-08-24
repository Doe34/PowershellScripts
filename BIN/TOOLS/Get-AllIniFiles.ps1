function Get-AllIniFiles
{    #Create an hashtable variable 
    [hashtable]$Return = @{} 

	$Return.scriptName = split-path -leaf $MyInvocation.MyCommand.Definition
	$Return.rootPath = split-path -parent $MyInvocation.MyCommand.Definition
	$IniFiles = gci -re $Return.rootPath -in *.ini

	foreach ( $item in $IniFiles ) {
		$item.FullName
	}

}