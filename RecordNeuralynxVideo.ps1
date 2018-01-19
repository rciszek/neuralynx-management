<#
Powershell script for scheduled recording using Neuralynx video EEG system.
Parameters:
	TaskID : The ID of the task defining the boxes asssigned to the task in the box_configuration file.
			 The task will skip the rows in the configuration where value of column "Task" does not correspond 
			 to TaskID.
Required files:
	config.json : Configuration recording task configuration file
	box_configuration.csv (default name) : A camera-animal configuration file defining 
											the correspondence between cameras and animals

Support: ciszek@uef.fi											
#>

param (
    [Parameter(Mandatory=$true)][int]$task = 1
 )
Set-StrictMode -Version 2.0

Import-Module ($PSScriptRoot + "\" + "AppendToLog.psm1") -Force
Import-Module ( $PSScriptRoot + "\" + "CreatePath.psm1") -Force

$currentTaskName = "VideoRecordingTask" + $task
AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Initializing task ") $task
#Read configuration from JSON file.
$config = Get-Content ( $PSScriptRoot + "\" + "config.json" ) | Out-String | ConvertFrom-Json
#Read the box-animal configuration
$boxConfiguration = Import-CSV( $PSScriptRoot + "\" + $config.boxConfig) -Delimiter ";"

#Calculate the maximum number of windows per row
$windowsPerRow = [Math]::Floor( ($config.displaySize[0] / $config.videoWindowSize[0]) )

$columnCount = 0
$rowCount = 0

#Start each camera and tile the video displays to cover the whole screen
for ( $i=0; $i -lt $boxConfiguration.Box.Length; $i++ )
{
	if ( $columnCount -gt $windowsPerRow )
	{
		$rowCount++
		$columnCount = 0
	}
	#If the camera is specifically set to NOT record, do not record. In the case of "yes" or typos, perform recording. 
	if ( $boxConfiguration.Recording[$i] -eq "no" ) {
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Not recording using " + $boxConfiguration.Camera[$i]  ) $task	
		continue
	}
	
	if ($boxConfiguration.Task[$i] -eq $Task ) {
 
		$path = CreatePath $config.videoTargetDrive $boxConfiguration.Project[$i] $boxConfiguration.Cohort[$i] $boxConfiguration.Animal[$i] $config.dateFormat		
		if ( (Test-Path $path) -eq $false ) {
			AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("ERROR: Path " + $path + " does not exist") $task
			continue
		}
		
		#Call the recording software with
		$output = &$config.MSVM -p -s $boxConfiguration.Camera[$i] -p $path -r -t $config.timeToExit -d [($columnCount*$config.videoWindowSize[0]),($rowCount*$config.videoWindowSize[0]),($config.videoWindowSize[0]),($config.videoWindowSize[1])]  -r
		$columnCount++
		Start-sleep -m $config.windowDelay
		AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Recording using " + $boxConfiguration.Camera[$i] + " from " +  $boxConfiguration.Box[$i] + " with output " + $output) $task			
	}
}

