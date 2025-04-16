param(
	[string]$Path = ".",
	[int]$Depth = 3
)

Import-Module Menu
	
$solutions = $null

if ((Test-Path -Path $Path -PathType Container)) {
	$solutions = (Get-ChildItem -Path $Path -Include "*.sln", "*.slnx" -Recurse -Depth $Depth)
} else {
	Write-Error "Cannot resolve $Path"
	return
}

$solutionPath = $null;

if ($null -ne $solutions && $solutions.Count -gt 0) {
	if ($solutions.Count -gt 1) {
		if ((Get-Host).Version.Major -gt 5) {
			$index = Menu -Items @($solutions.Name) -ReturnIndex

			if ($null -eq $index) {
				exit
			}

			$solutionPath = $solutions[$index].FullName
		} else {
			$solutionPath = $solutions[0].FullName
		}
	} else {
		$solutionPath = $solutions.FullName
	}
}

if ($null -ne $solutionPath) {
	Write-Host "Opening $solutionPath ..."
	Invoke-Item $solutionPath
} else {
	Write-Host "No solution file have been found."
}
