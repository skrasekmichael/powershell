$path = $args[0]
$solutions = $null

if ($null -eq $path) {
	$solutions = (Get-ChildItem -Path "." -Filter "*.sln" -Recurse)
} elseif ((Test-Path -Path $path -PathType Container)) {
	$solutions = (Get-ChildItem -Path $path -Filter "*.sln" -Recurse)
} else {
	Write-Error "Cannot resolve $path"
	return
}

if ($null -ne $solutions) {
	if ($solutions.Count -gt 1) {
		if ((Get-Host).Version.Major -gt 5) {
			$index = menu @($solutions.Name) -ReturnIndex

			if ($null -eq $index) {
				exit
			}

			$path = $solutions[$index].FullName
		} else {
			$path = $solutions[0].FullName
		}
	} else {
		$path = $solutions.FullName
	}
}

if ($null -ne $Path) {
	Write-Host "Opening $path ..."
	Invoke-Item $path
}
