param (
	[string]$Path = ".",
	[switch]$Root = $false
)

Import-Module Utils

$Path = Resolve-Path $Path -ErrorAction Stop

if ($Root) {
	Get-ChildItem -LiteralPath $Path -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $null -eq $_.LinkTarget } | ForEach-Object {
		$size = 0
		Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
			$size += $_.Length
		}
		New-Object psobject -Property @{
			Path = [System.IO.Path]::GetRelativePath($Path, $_.FullName)
			Size = (Format-Size -Size $size)
		}
	}
} else {
	$size = 0
	Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
		$size += $_.Length
	}
	return Format-Size -Size $size
}
