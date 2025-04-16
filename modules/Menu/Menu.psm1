function DrawMenu {
	param (
		[array]$Items,
		[int]$Position
	)

	$count = $Items.length
	for ($i = 0; $i -le $count; $i++) {
		if ($null -ne $Items[$i]) {
			$item = $Items[$i]
			if ($i -eq $Position) {
				Write-Host "> $($item)" -ForegroundColor Green
			} else {
				Write-Host "  $($item)"
			}
		}
	}
}

function Menu {
	param (
		[array]$Items,
		[switch]$ReturnIndex = $false
	)

	$EnterKey = 13
	$EscKey = 27
	$HomeKey = 36
	$EndKey = 35
	$UpKey = 38
	$DownKey = 40

	$keyCode = 0
	$pos = 0
	if ($Items.Length -gt 0)
	{
		try {
			[System.Console]::CursorVisible = $false
			DrawMenu $Items $pos
			While ($keyCode -ne $EnterKey -and $keyCode -ne $EscKey) {
				$press = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				$keyCode = $press.VirtualKeyCode

				if ($keyCode -eq $UpKey) { $pos-- }
				if ($keyCode -eq $DownKey) { $pos++ }
				if ($keyCode -eq $HomeKey) { $pos = 0 }
				if ($keyCode -eq $EndKey) { $pos = $Items.Length - 1 }

				if ($pos -lt 0) {
					$pos = 0
				} elseif ($pos -ge $Items.Length) {
					$pos = $Items.Length - 1
				}

				if ($keyCode -eq $EscKey) {
					$pos = $null
				} else {
					$startPos = [System.Console]::CursorTop - $Items.Length
					[System.Console]::SetCursorPosition(0, $startPos)
					DrawMenu $Items $pos
				}
			}
		} finally {
			[System.Console]::SetCursorPosition(0, $startPos + $Items.Length)
			[System.Console]::CursorVisible = $true;
		}
	} else {
		$pos = $null
	}

	if ($ReturnIndex -eq $false -and $null -ne $pos) {
		return $Items[$pos]
	} else {
		return $pos
	}
}

Export-ModuleMember -Function Menu
