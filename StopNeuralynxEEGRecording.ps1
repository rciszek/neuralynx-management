<#
Script which stops EEG recording
Support : ciszek@uef.fi
#>
Set-StrictMode -Version 2.0

Import-Module ( $PSScriptRoot + "\" + "AppendToLog.psm1") -Force

$currentTaskName = "EEGRecordingTask"

#Read configuration from JSON file.
$config = Get-Content ( $PSScriptRoot + "\" + "config.json" ) | Out-String | ConvertFrom-Json

$output = & $config.SendNetComCommand -StopRecording

AppendToLog $PSScriptRoot ($currentTaskName  +".log") ("Task stopped with output " + $output)