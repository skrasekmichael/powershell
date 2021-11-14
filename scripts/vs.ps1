$path = $args[0];
if ($null -eq $args[0]) {
	$path = (Get-ChildItem -Path "." -Filter "*.sln" -Recurse | Select-Object -first 1).FullName
} elseif ((Test-Path -Path $args[0] -PathType Container)) {
	$path = (Get-ChildItem -Path $args[0] -Filter "*.sln" -Recurse | Select-Object -first 1).FullName
} else {
	Write-Error "Cannot resolve $($args[0])"
	return
}

Write-Host "Opening $path ..."
Invoke-Item $path
