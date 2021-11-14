function Get-Scene { 
	param (
		[string]$Path, 
		[timespan]$Start, 
		[timespan]$Duration, 
		[string]$Output
	)

	if ([System.IO.File]::Exists("$Output")) {
		$yn = Read-Host "Rewrite? [y/n]"
		if ($yn -eq "y") {
			Remove-Item $Output
		} else {
			Write-Host "skiped [$Output]" -ForegroundColor Yellow
			return
		}
	}

	Write-Host "file [$Path]"
	Write-Host "cutting ... " -NoNewline
	ffmpeg.exe -loglevel panic -ss $Start.ToString() -i $Path -t $Duration.ToString() -c:v libx264 -c:a aac -strict experimental -b:a 128k $Output
	Write-Host "DONE [$Output] [$Duration]" -ForegroundColor Green
}

function Merge-Files {
	param (
		[string]$List,
		[string]$Output
	)

	Write-Host "merging ... " -NoNewline
	ffmpeg.exe -loglevel panic -f concat -safe 0 -i $List -c copy $Output
	Write-Host "DONE" -ForegroundColor Green
}

function Add-Subtitles {
	param (
		[string]$Path,
		[string]$Text, 
		[timespan]$Start,
		[timespan]$Duration,
		[int]$Index
	)

	$from = $Start.ToString('hh\:mm\:ss\,fff')
	$to = ($Start + $Duration).ToString('hh\:mm\:ss\,fff')

	Add-Content -Path $Path -Value "$Index`r`n$from --> $to`r`n$Text`r`n"
}

function LoadData {
	param (
		[string]$File, 
		[int]$Start,
		[string]$Root
	)

	$index = 0
	
	$files = Get-ChildItem -Path $Root/* -File -Include *.avi, *.mp4, *.mkv
	foreach ($line in Get-Content -Path $File -Encoding UTF8) {
		$bool = 0
		# 0 defaul - true
		# 1 priority - true
		# 2 skiped - false
		# 3 comment - false

		if ($line.StartsWith("#")) {
			$line = $line.Substring(1)
			$bool = 3
		} 
		
		if ($index -lt $Start) {
			$bool = 2
		}

		if ($line.StartsWith("$")) {
			$line = $line.Substring(1)
			$bool = 1
		}

		$params = $line -split ";"
		$match = $params[0]

		$possible_files = ($files | Where-Object { $_.Name -match "$match" })
		$len = ($possible_files | Measure-Object).Count
		if ($len -eq 0) {
			Write-Host "filed not found [$match]" -ForegroundColor Red
		} elseif ($len -gt 1) {
			Write-Host "multiple files with this match [$match]" -ForegroundColor Red
		} else {
			$inputfile = $possible_files[0]

			$title = $params[1]
			$time = $params[2] -split "-"

			$from = [TimeSpan]$time[0]
			$to = [TimeSpan]$time[1]

			New-Object psobject -Property @{
				Match = $match
				From = $from
				To = $to
				Title = $title
				Status = $bool
				Start = $next
				File = $inputfile
			}

			$index += 1
		}
	}
}

function Play {
	param (
		[string]$File,
		[timespan]$Start,
		[timespan]$Duration
	)

	$ci = New-Object -TypeName CultureInfo("en")
	$f = $Start.TotalSeconds.ToString("#.#", $ci)
	$t = ($Start + $Duration).TotalSeconds.ToString("#.#", $ci)

	vlc.exe -I dummy --video-x=480 --video-y=1 --no-video-deco --no-embedded-video --start-time=$f --stop-time=$t $File
	#$a = ffplay.exe -v quiet -ss $Start -t $Duration -vf drawtext="text='%{pts\:hms}':box=1:x=(tw):y=(2*lh)" $File
}

function SpecifyStart {
	param (
		[timespan]$Time,
		[string]$File
	)

	$time = $Time
	while ($TRUE) {
		Write-Host "specifying start [$Time] to [$time]"
		Play -File $File -Start $time -Duration (New-TimeSpan -Seconds 4)
		$delta = Read-Host "Delta"
		if ($delta -eq "") {
			break
		} else {
			$n = [int]::Parse($delta)
			$time += ([timespan]::FromMilliseconds($n))
		}
	}

	return $time
}

function SpecifyEnd {
	param (
		[timespan]$Time,
		[string]$File
	)

	$time = $Time
	while ($TRUE) {
		Write-Host "specifying end [$Time] to [$time]"
		Play -File $File -Start ($time - (New-TimeSpan -Seconds 4)) -Duration (New-TimeSpan -Seconds 4)
		$delta = Read-Host "Delta"
		if ($delta -eq "") {
			break
		} else {
			$n = [int]::Parse($delta)
			$time += ([timespan]::FromMilliseconds($n))
		}
	}

	return $time
}

function RewriteLine {
	param (
		[string]$File,
		[int]$Line,
		[string]$Data
	)

	$lines = Get-Content -Path $File -Encoding UTF8
	$lines[$Line] = $Data
	$lines | Set-Content -Path $File -Encoding UTF8
}

function Specify {
	param (
		$Data,
		[string]$File
	)

	$index = 0
	foreach ($obj in $Data) {
		Write-Host ("specifying file [" + $obj.File + "]")

		$newstart = SpecifyStart -Time $obj.From -File $obj.File
		$obj.From = $newstart
		RewriteLine -File $File -Line $index -Data ($obj.Match + ";" + $obj.Title + ";" + $obj.From.ToString('hh\:mm\:ss\.fff') + "-" + $obj.To.ToString('hh\:mm\:ss\.fff'))
		
		$newend = SpecifyEnd -Time $obj.To -File $obj.File
		$obj.To = $newend
		RewriteLine -File $File -Line $index -Data ($obj.Match + ";" + $obj.Title + ";" + $obj.From.ToString('hh\:mm\:ss\.fff') + "-" + $obj.To.ToString('hh\:mm\:ss\.fff'))

		$index += 1
	}
}

function Main { 
	param (
		[string]$Root,
		[int]$Start
	)

	$file = "$Root/best.txt"
	$list = "$Root/scenes/list.txt"
	$srt = "$Root/scenes/best-scenes.srt"
	$merged = "$Root/scenes/best-scenes.mp4"
	Write-Host "input file [$file]"

	if (-not (Test-Path "$Root/scenes" -PathType Container)) {
		New-Item "$Root/scenes" -ItemType "directory" >$null
	}

	if ([System.IO.File]::Exists($srt)) {
		Remove-Item $srt
	}

	if ([System.IO.File]::Exists($list)) {
		Remove-Item $list
	}

	$data = LoadData -File $file -Start $Start -Root $Root
	$yn = Read-Host "Do you want to specify timespans [y/n]"
	if ($yn -eq "y") {
		Specify -Data $data -File $file
	}

	$yn = Read-Host "Do you want to continue? [y/n]"
	if ($yn -eq "y") {
		$index = 0
		$next = New-TimeSpan -Seconds 0

		foreach ($obj in $data) {
			$inputfile = $obj.File
			$outputfile = "best-scene-" + $obj.Match + "-" + $obj.Title + ".mp4"
			$duration = $obj.To - $obj.From

			if ($obj.Status -lt 2) {
				Get-Scene -Path $inputfile.Name -Start $obj.From -Duration $duration -Output "$Root/scenes/$outputfile"
			} else {
				Write-Host ("skiped [$inputfile] [" + $obj.Title + "]") -ForegroundColor Yellow
			}

			Add-Subtitles -Path $srt -Text $obj.Title -Start ($next + (New-TimeSpan -Seconds 1)) -Duration (New-TimeSpan -Seconds 4) -Index $index
			Add-Content -Path $list -Value "file '$outputfile'"

			$next += $duration
			$index += 1
		}

		$yn = Read-Host "Do you want to merge files? [y/n]"
		if ($yn -eq "y") {
			if ([System.IO.File]::Exists($merged)) {
				Remove-Item $merged
			}

			Merge-Files -List $list -Output $merged
		}
	}
}

Main -Root $args[0] -Start $args[1]
