param (
	$Name = "System",
	$Wrn = (Get-Date).AddMinutes(-20),
	$Err = (Get-Date).AddHours(-1),
	$Crit = (Get-Date).AddDays(-1)
)

$warning_list = Get-WinEvent -FilterHashTable @{LogName=$Name;Level=3;StartTime=$Wrn} -ErrorAction SilentlyContinue
$error_list = Get-WinEvent -FilterHashTable @{LogName=$Name;Level=2;StartTime=$Err} -ErrorAction SilentlyContinue
$critical_list = Get-WinEvent -FilterHashTable @{LogName=$Name;Level=1;StartTime=$Crit} -ErrorAction SilentlyContinue

$list = [System.Collections.ArrayList]::new()

$warning_list | ForEach-Object { $list.Add($_) | Out-Null }
$error_list | ForEach-Object { $list.Add($_) | Out-Null }
$critical_list | ForEach-Object { $list.Add($_) | Out-Null }

foreach ($event in $list | Sort-Object) {
	$level = switch ($event.Level)
	{
		1 { "Critical" }
		2 { "Error" }
		3 { "Warning" }
	}
	New-Object psobject -Property @{
		Level = $level
		TimeCreated = $event.TimeCreated
		Message = $event.Message
	}
}
