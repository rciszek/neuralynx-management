<#
Function for appending entries to a log file

Parameters:
	 path : Log file path
	 fileName : Name of the log file
	 message : Message to be logged
	 
Support: ciszek@uef.fi	
#>
function AppendToLog {
param(
		[String] $path,
		[String] $fileName,
		[String] $message,	
		[String] $taskName = ""			
    ) 
	
	$logFilePath = $path + "\" +  $fileName;
	#Create the log file if it does not exist
	if ( ( Test-Path $logFilePath) -eq $false ) {
		New-Item $logFilePath
	}
	
	Add-content ($path + "\" +  $fileName) -value ( ( Get-Date -Format "dd:MMM:yy hh:mm:ss") + "`t" + $taskName + "`t" + $message)
}