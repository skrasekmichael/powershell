param(
	[string]$Path,
	[int]$Depth = -1,
	[switch]$Raw = $false
)
	
Import-Module Utils

$root = Resolve-Path "."
if ("" -ne $Path) {
	$root = Resolve-Path $Path
}

function Write-Info {
	param (
		[string]$Path,
		[int]$CurrentDepth
	)

	if (($CurrentDepth -lt $Depth) -or ($Depth -eq -1)) {
		$folders = Get-ChildItem -LiteralPath $Path -Directory
		foreach ($folder in $folders) {
			Write-Info -Path $folder.FullName -CurrentDepth ($CurrentDepth + 1)
		}
	}
	
	$files = Get-ChildItem -LiteralPath $Path -File -Include *.avi, *.mp4, *.mkv, *.wmv
	foreach ($file in $files) {
		$json = ffprobe -v quiet -print_format json -show_format -show_streams $file.FullName | ConvertFrom-Json
		$index = Get-VideoStreamIndex -Json $json
		$counts = Get-SubtitlesCounts -Json $json
		New-Object psobject -Property @{
			File = [System.IO.Path]::GetRelativePath($root, $file.FullName)
			Resolution = "$($json.streams[$index].Width)x$($json.streams[$index].Height)"
			Size = Format-Size -Size $file.Length
			Duration = New-TimeSpan -Seconds ($json.format.duration)
			Codec = $json.streams[$index].codec_name
			Framerate = Format-Double -Value (Invoke-Expression ($json.streams[$index].r_frame_rate)) -After " fps"
			Bitrate = Format-bps -Value $json.format.bit_rate
			Details = $json.streams[$index].codec_long_name
			Subs = $counts.Subs
			Auds = $counts.Auds
		}
	}
}

function Get-VideoStreamIndex {
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

function Get-SubtitlesCounts {
	param (
		[psobject]$Json
	)
	
	$subs = 0
	$auds = 0
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
	Write-Info -Path $root -CurrentDepth 0 | Format-Table File, @{Expression={$_.Size}; Label="Size      "}, Resolution, Codec, Duration, Framerate, Auds, Subs, Bitrate, Details
}
