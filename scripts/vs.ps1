param(
	[string]$Path = ".",
	[int]$Depth = 3
)

$solutions = $null

if ((Test-Path -Path $Path -PathType Container)) {
	$solutions = (Get-ChildItem -Path $Path -Filter "*.sln" -Recurse -Depth $Depth)
} else {
	Write-Error "Cannot resolve $Path"
	return
}

if ($null -ne $solutions) {
	if ($solutions.Count -gt 1) {
		if ((Get-Host).Version.Major -gt 5) {
			$index = menu @($solutions.Name) -ReturnIndex

			if ($null -eq $index) {
				exit
			}

			$Path = $solutions[$index].FullName
		} else {
			$Path = $solutions[0].FullName
		}
	} else {
		$Path = $solutions.FullName
	}
}

if ($null -ne $Path) {
	Write-Host "Opening $Path ..."
	Invoke-Item $Path
}
