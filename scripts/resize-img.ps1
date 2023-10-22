using namespace System.Drawing

param(
	[Parameter(Mandatory = $true)]
	[string]$In,
	[Parameter(Mandatory = $true)]
	[string]$Out,
	[Parameter(Mandatory = $true, ParameterSetName = "SizeSet")]
	[int]$MaxSize,
	[Parameter(Mandatory = $true, ParameterSetName = "WidthSet")]
	[int]$NewWidth,
	[Parameter(Mandatory = $true, ParameterSetName = "HeightSet")]
	[int]$NewHeight,
	[int]$BytesPerPixel = 3
)

$path = Resolve-Path $In
if ((Test-Path $path -PathType Leaf) -eq $false) {
	Write-Error "File $($In) not found.";
	exit
}

$img = [System.Drawing.Image]::FromFile($path);

switch ($PSCmdlet.ParameterSetName) {
	"WidthSet" {
		$NewHeight = ($img.Height * $NewWidth) / $img.Width;
	}
	"HeightSet" {
		$NewWidth = ($img.Width * $NewHeight) / $img.Height;
	}
	"SizeSet" {
		$NewWidth = [System.Math]::Sqrt(($MaxSize * $img.Width) / ($BytesPerPixel * $img.Height));
		$NewHeight = ($img.Height * $NewWidth) / $img.Width;
	}
	default {
		Write-Error "Please specify exactly one of NewWidth, NewHeight, or MaxSize.";
		exit
	}
}

Write-Host "Original: $($img.Width)x$($img.Height)"
Write-Host "New:      $($NewWidth)x$($NewHeight)"

$bmp = [System.Drawing.Bitmap]::new([int]$NewWidth, [int]$NewHeight);
$graphics = [System.Drawing.Graphics]::FromImage($bmp);
$graphics.DrawImage($img, 0, 0, $NewWidth, $NewHeight);
$img.Dispose();

$savePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Out)
Write-Host "Writing to $($savePath) ...";
$bmp.Save($savePath);
$bmp.Dispose();
