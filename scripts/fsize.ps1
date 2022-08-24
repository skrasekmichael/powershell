param (
	[string]$Path = "."
)

Import-Module Utils

if (Test-Path $Path -PathType Container) {
	$Measure = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
	return Format-Size -Size $Measure.Sum
} else {
	Write-Error "Parameter [$Path] isn't path to directory."
}
