<#
Script for setting up project folders for recording.

Support: ciszek@uef.fi
#>

Import-Module ( $PSScriptRoot + "\" + "AppendToLog.psm1") -Force
Import-Module ( $PSScriptRoot + "\" + "CreatePath.psm1") -Force

$currentTaskName = "SetupTask"
AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Initializing setup ")

#Read configuration from JSON file.
$config = Get-Content ( $PSScriptRoot + "\" + "config.json" ) | Out-String | ConvertFrom-Json
#Read the box-animal configuration
$boxConfiguration = Import-CSV( $PSScriptRoot + "\" + $config.boxConfig) -Delimiter ";"

#Loop through all animals
for ( $i=0; $i -lt $boxConfiguration.Animal.Length; $i++ )
{
	$path = CreatePath $config.videoTargetDrive $boxConfiguration.Project[$i] $boxConfiguration.Cohort[$i] $boxConfiguration.Animal[$i] $config.dateFormat	
	if ( (Test-Path $path) -eq $true  ) {
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("ERROR: Path " + $path + " already exists")
	}
	else {
		mkdir $path
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Path " + $path + " created")		
	}

}
