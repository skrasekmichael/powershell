param (
	[string]$Path = "."
)

Import-Module Utils

if (Test-Path $Path) {
	$Measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
	return Format-Size -Size $Measure.Sum
}
