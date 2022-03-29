using namespace System.Drawing

param(
	[int]$Width,
	[int]$Cols,
	[array]$Files,
	[string]$Output,
	[int]$Space = 10,
	[string[]]$ColTitles = $null,
	[string[]]$RowTitles = $null,
	[string[]]$Titles = $null,
	[string]$FontName = "Calibri",
	[int[]]$FontSizes = @(15, 15, 15),
	[System.Drawing.Color[]]$FontColors = @([System.Drawing.Color]::Black, [System.Drawing.Color]::Black, [System.Drawing.Color]::Black)
)

$filePaths = [System.Collections.ArrayList]::new()
foreach ($file in $Files) {
	$path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($file)
	if (Test-Path $path -PathType Leaf) {
		$filePaths.Add($path) | Out-Null
	}
}

if ($filePaths.Count -lt 1) {
	exit
}

if ($FontSizes.Count -ne 3) {
	exit
}

$w = ($Width + $Space) * $Cols + $Space
$rows = [Math]::Ceiling($filePaths.Count / $Cols)

$img = [System.Drawing.Image]::FromFile($filePaths[0])
$h = (($img.Height * $Width) / $img.Width + $Space) * $rows + $space
$img.Dispose()

$left = 0;
if ($null -ne $RowTitles) {
	$left = $FontSizes[1]
}

$top = 0;
if ($null -ne $ColTitles) {
	$top = $FontSizes[0]
}

$bmp = New-Object System.Drawing.Bitmap(($w + $left), ($h + $top))
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

$graphics.Clear([System.Drawing.Color]::White);

if ($null -ne $ColTitles) {
	$colFont = [System.Drawing.Font]::new($FontName, $FontSizes[0], [System.Drawing.FontStyle]::Regular)
	$colBrush = [System.Drawing.SolidBrush]::new($FontColors[0])

	for ($x = 0; $x -lt $Cols; $x++) {
		$graphics.DrawString($ColTitles[$x], $colFont, $colBrush, $left + $Space + $x * ($Width + $Space), 0)
	}
}

$index = 0;
while ($index -lt $filePaths.Count) {
	for ($i = 0; $i -lt $Cols; $i++) {
		if ($index -eq $filePaths.Count) {
			break
		}

		Write-Host "Loading image [$($filePaths[$index])]"
		$img = [System.Drawing.Image]::FromFile($filePaths[$index])

		$Height = ($img.Height * $Width) / $img.Width;

		$x = $index % $Cols
		$y = ($index - $x) / $Cols

		$graphics.DrawImage($img, $left + $Space + $x * ($Width + $Space), $top + $Space + $y * ($Height + $Space), $Width, $Height)
		$img.Dispose()

		$index++;
	}
}

$savePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)
Write-Host "Saving file [$savePath]"
$bmp.Save($savePath);
$bmp.Dispose()
