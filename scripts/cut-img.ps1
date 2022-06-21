using namespace System.Drawing

param (
	[string]$In,
	[string]$Out,
	[int]$Left = 0,
	[int]$Top = 0,
	[int]$Bottom = 0,
	[int]$Right = 0,
	[int]$W = -1,
	[int]$H = -1
)

$inputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($In)
$outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Out)

$img = [System.Drawing.Image]::FromFile($inputPath)

if ($W -lt 0) {
	$W = $img.Width - $Left - $Right
}

if ($H -lt 0) {
	$H = $img.Height - $Top - $Bottom
}

$bmp = New-Object System.Drawing.Bitmap($W, $H)

for ($y = 0; $y -lt $H; $y++) {
	for ($x = 0; $x -lt $W; $x++) {
		$pixel = $img.GetPixel($x + $Left, $y + $Top)
		$bmp.SetPixel($x, $y, $pixel)
	}
}

$img.Dispose()
$bmp.Save($outputPath)
$bmp.Dispose()
