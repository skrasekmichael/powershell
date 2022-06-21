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
	[int]$Left = 0,
	[int]$Top = 0,
	[System.Drawing.Color[]]$FontColors = @([System.Drawing.Color]::Black, [System.Drawing.Color]::Black, [System.Drawing.Color]::Black),
	[int]$Aligment = 4
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
$Height = ($img.Height * $Width) / $img.Width;
$img.Dispose()

$bmp = New-Object System.Drawing.Bitmap([int]($w + $Left), [int]($h + $Top))
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

$graphics.Clear([System.Drawing.Color]::White);

$stringFormat = [System.Drawing.StringFormat]::new()
$stringFormat.Alignment = $Aligment % 3
$stringFormat.LineAlignment = ($Aligment - $Aligment % 3) / 3
$stringFormat.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap + [System.Drawing.StringFormatFlags]::NoClip

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

		$graphics.DrawImage($img, $Left + $Space + $x * ($Width + $Space), $Top + $Space + $y * ($Height + $Space), $Width, $Height)
		$img.Dispose()

		$index++;
	}
}

if ($null -ne $ColTitles) {
	$colFont = [System.Drawing.Font]::new($FontName, $FontSizes[0], [System.Drawing.FontStyle]::Regular)
	$colBrush = [System.Drawing.SolidBrush]::new($FontColors[0])

	for ($x = 0; $x -lt $Cols; $x++) {
		$rec = [System.Drawing.RectangleF]::new($Left + $Space + $x * ($Width + $Space), 0, $Width, $Top)
		$graphics.DrawString($ColTitles[$x], $colFont, $colBrush, $rec, $stringFormat)
	}
}

if ($null -ne $RowTitles) {
	$rowFont = [System.Drawing.Font]::new($FontName, $FontSizes[1], [System.Drawing.FontStyle]::Regular)
	$rowBrush = [System.Drawing.SolidBrush]::new($FontColors[1])

	for ($y = 0; $y -lt $rows; $y++) {
		$rec = [System.Drawing.RectangleF]::new(0, $Top + $Space + $y * ($Height + $Space), $Left, $Height)
		$graphics.DrawString($RowTitles[$y], $rowFont, $rowBrush, $rec, $stringFormat)
	}
}

$savePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)
Write-Host "Saving file [$savePath]"
$bmp.Save($savePath);
$bmp.Dispose()
