<#
Powershell script for scheduled recording using Neuralynx video EEG system.
Required files:
	config.json : Configuration recording task configuration file
	box_configuration.csv (default name) : A box-animal configuration file defining 
											the correspondence between boxes and animals

Support: ciszek@uef.fi											
#>

param(
	[Boolean]$overWrite = $false
)

Set-StrictMode -Version 2.0

Import-Module ( $PSScriptRoot + "\" + "AppendToLog.psm1") -Force
Import-Module ( $PSScriptRoot + "\" + "CreatePath.psm1") -Force

$currentTaskName = "EEGRecordingTask"
AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Initializing task ")
#Read configuration from JSON file.
$config = Get-Content ( $PSScriptRoot + "\" + "config.json" ) | Out-String | ConvertFrom-Json
#Read the box-animal configuration
$boxConfiguration = Import-CSV( $PSScriptRoot + "\" + $config.boxConfig) -Delimiter ";"

#Loop through all animals
for ( $i=0; $i -lt $boxConfiguration.Animal.Length; $i++ )
{
	#If the device is specifically set to NOT record, do not record. In the case of "yes" or typos, perform recording. 
	if ( $boxConfiguration.Recording[$i] -eq "no" ) {
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Not recording from " + $boxConfiguration.Box[$i]  )	
		continue
	}
	
	$path = CreatePath $config.eegTargetDrive $boxConfiguration.Project[$i] $boxConfiguration.Cohort[$i] $boxConfiguration.Animal[$i] $config.dateFormat
	if ( (Test-Path $path) -eq $false ) {
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Path " + $path + " does not exist")
		continue
	}
	
	for ($c=1; $c -le $config.channelsPerBox; $c++) {
		$fileName = ( "Cage"+$boxConfiguration.Box[$i] + "-" + $c ) 
		$path = CreatePath $config.videoTargetDrive $boxConfiguration.Project[$i] $boxConfiguration.Cohort[$i] $boxConfiguration.Animal[$i] $config.dateFormat	
		$filePath = $path + "\" + $fileName + $config.eegFormat
		$commandSetDataFile = "-SetDataFile " + $fileName + " " + $filePath
		$commandSetAcqEntProcessingEnabled = "-SetAcqEntProcessingEnabled " + $fileName + " True"
		
		if ( (Test-Path $filePath ) ) 
		{
			AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("WARNING: File already exists: channel " +  $c + " of box " + $boxConfiguration.Box[$i] + " measuring animal " +  $boxConfiguration.Animal[$i])
			if ( $overWrite -eq $false ) {
				AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("WARNING: Omitting channel " +  $c + " of box " + $boxConfiguration.Box[$i] + " measuring animal " +  $boxConfiguration.Animal[$i])
				continue
			}
			AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Overwriting channel " +  $c + " of box " + $boxConfiguration.Box[$i] + " measuring animal " +  $boxConfiguration.Animal[$i])	
		}
		$output = & $config.SendNetComCommand -command $commandSetDataFile  -command $commandSetAcqEntProcessingEnabled 2>&1			
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Recording channel " +  $c + " of box " + $boxConfiguration.Box[$i] + " measuring animal " +  $boxConfiguration.Animal[$i] + " with executable output: " + $output)							
	}
		
}

$output = & $config.SendNetComCommand -StartRecording 

AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Begin recording with output: " + $output) 
