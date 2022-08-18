param(
	[string]$Path,
	[int]$Depth,
	[switch]$Raw = $false
)
	
Import-Module Utils

$root = "."
if ("" -ne $Path) {
	$root = $Path;
}

function Write-Info {
	param (
		[string]$Path,
		[int]$CurrentDepth
	)

	if ($CurrentDepth -le $Depth) {
		$folders = Get-ChildItem $Path -Directory
		foreach ($folder in $folders) {
			Write-Info -Path ($Path + "/" + $folder.Name) -CurrentDepth ($CurrentDepth + 1)
		}
	}
	
	$files = Get-ChildItem -Path $Path/* -File -Include *.avi, *.mp4, *.mkv, *.wmv
	foreach ($file in $files) {
		$json = ffprobe -v quiet -print_format json -show_format -show_streams $file | ConvertFrom-Json
		$index = Get-Video-Stream -Json $json
		$counts = Get-Counts -Json $json
		New-Object psobject -Property @{
			File = ($Path + "/" + $file.Name)
			Resolution = ($json.streams[$index].Width.ToString() + "x" + $json.streams[$index].Height.ToString())
			Size = Format-Size -Size $file.Length
			Duration = New-TimeSpan -Seconds ($json.format.duration)
			Codec = $json.streams[$index].codec_name
			Details = $json.streams[$index].codec_long_name
			Subs = $counts.Subs
			Auds = $counts.Auds
		}
	}
}

function Get-Video-Stream {
	param (
		[psobject]$Json
	)

	$index = 0;
	foreach ($stream in $Json.streams) {
		if ($stream.codec_type -eq "video") {
			return $index
		}
		$index++
	}
	return -1
}

function Get-Counts {
	param (
		[psobject]$Json
	)
	
	$subs = 0;
	$auds = 0;
	foreach ($stream in $Json.streams) {
		if ($stream.codec_type -eq "subtitle") {
			$subs++
		} elseif ($stream.codec_type -eq "audio") {
			$auds++
		}
	}

	return New-Object psobject -Property @{
		Subs = $subs
		Auds = $auds
	}
}

if ($Raw) {
	Write-Info -Path $root -CurrentDepth 0
} else {
	Write-Info -Path $root -CurrentDepth 0 | Format-Table File, @{Expression={$_.Size}; Label="Size      "}, Resolution, Codec, Duration, Auds, Subs, Details
}
