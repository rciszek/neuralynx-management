<#
Function encapsulating the project path creation

Parameters:
	drive : Path on which the project folder resides
	project : Name of the project
	cohort : Name of the cohort
	animal : Animal ID
	dateFormat : Dateformat used for folder timestamping
	 
Support: ciszek@uef.fi	
#>
function CreatePath {
param(
		[String] $drive,
		[String] $project,
		[String] $cohort,	
		[String] $animal,
		[String] $dateFormat = 'dd_MMM_yy'
    ) 
	$currentDate = Get-Date -Format $dateFormat
	$path = $drive + "\" + $project + "\" + $cohort + "\" + $currentDate + "\" +$animal
	
	return $path
}