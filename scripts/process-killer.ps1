param(
	[Parameter(Mandatory = $true)]
	[string]$ProcessName,
	[int]$DelayMs = 5000
)

while ($true)
{

	$processes = Get-Process | Where-Object { $_.ProcessName -eq $ProcessName }
	foreach ($process in $processes)
	{
		Write-Host (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")
		taskkill.exe -f -pid $process.Id
	}

	Start-Sleep -Milliseconds $DelayMs
}
