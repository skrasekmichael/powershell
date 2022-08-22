using namespace System.Drawing

param (
	[string]$I1,
	[string]$I2,
	[string]$Out,
	$Zoom = 0.5,
	$GS = $true
)

$path1 = Resolve-Path $I1
$path2 = Resolve-Path $I2
$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Out)

$bmp1 = [System.Drawing.Image]::FromFile($path1)
$bmp2 = [System.Drawing.Image]::FromFile($path2)

Write-Host "Comparing images [$I1][$I2]..." -NoNewline
if (!($bmp1.Width -eq $bmp2.Width -and $bmp1.Height -eq $bmp2.Height)) {
	$bmp1.Dispose();
	$bmp2.Dispose();

	Write-Output "Resolution of images doesnt match. "
	exit
}

$bmp = New-Object System.Drawing.Bitmap($bmp1.Width, $bmp1.Height)

$pixels = 0
$totalDiff = 0

for ($y = 0; $y -lt $bmp.Height; $y++) {
	for ($x = 0; $x -lt $bmp.Width; $x++) {
		$c1 = $bmp1.GetPixel($x, $y)
		$c2 = $bmp2.GetPixel($x, $y)

		if ($GS) {
			$newColor = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)
			if ($c1.R -ne $c2.R) {
				$pixels++
				$d = $c1.R - $c2.R
				$totalDiff += [Math]::Abs($d)
				$diff = [Math]::Clamp($d * $Zoom, -255, 255)
				if ($diff -lt 0) {
					$newColor = [System.Drawing.Color]::FromArgb(255, $diff * -1, 0, 10)
				} else {
					$newColor = [System.Drawing.Color]::FromArgb(255, 0, $diff, 10)
				}
			}
		} else {
			$newColor = [System.Drawing.Color]::FromArgb(255, 127, 127, 127)
			if (!($c1.R -eq $c2.R -and $c1.G -eq $c2.G -and $c1.B -eq $c2.B)) {
				$pixels++
				$diffR = [Math]::Clamp(($c1.R - $c2.R) * $Zoom, -127, 127)
				$diffG = [Math]::Clamp(($c1.G - $c2.G) * $Zoom, -127, 127)
				$diffB = [Math]::Clamp(($c1.B - $c2.B) * $Zoom, -127, 127)
				$newColor = [System.Drawing.Color]::FromArgb(255, 127 + $diffR, 127 + $diffG, 127 + $diffB)
			}
		}

		$bmp.SetPixel($x, $y, $newColor)
	}
}
Write-Host "DONE"

$bmp1.Dispose()
$bmp2.Dispose()

$total = $($bmp.Width * $bmp.Height)
$perc = 100 * $pixels / $total

if ($pixels -eq 0) {
	Write-Host "Images have no differences!" -ForegroundColor Green
} else {
	$avg = $totalDiff / $pixels
	Write-Host "Image compare result: $pixels/$total different pixels [$($perc.ToString("0.00"))%]"
	Write-Host "Average difference: " -NoNewline
	if ($avg -lt 4) {
		Write-Host $avg
	} else {
		if ($avg -lt 10) {
			Write-Host $avg -ForegroundColor Yellow
		} else {
			Write-Host $avg -ForegroundColor Red
		}
	}
	Write-Host "Saving difflog [$output]"
	$bmp.Save($output)
}
$bmp.Dispose()
