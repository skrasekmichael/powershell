param(
	[int]$X = 0,
	[int]$Y = 0,
	[int]$Delay = 5
)

Write-Output "Select window to move, window moves in $($Delay)"
while ($Delay -gt 0) {
	Start-sleep 1
	$Delay--
	Write-Output $Delay
}

$hwnd = [User32]::GetForegroundWindow()

if ($hwnd -ne [IntPtr]::Zero) {
	[User32]::SetWindowPos($hwnd, [User32]::HWND_TOP, $X, $Y, 0, 0, [User32]::SWP_NOSIZE) | Out-Null
	Write-Host "Window moved to ($($X),$($Y))."
} else {
	Write-Error "No window found."
}
