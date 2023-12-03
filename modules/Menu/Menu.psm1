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

    $vkeycode = 0
    $pos = 0
    if ($Items.Length -gt 0)
	{
		try {
			[System.Console]::CursorVisible = $false
			DrawMenu $Items $pos
			While ($vkeycode -ne 13 -and $vkeycode -ne 27) {
				$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
				$vkeycode = $press.virtualkeycode
				if ($vkeycode -eq 38) { $pos-- }
				if ($vkeycode -eq 40) { $pos++ }
				if ($vkeycode -eq 36) { $pos = 0 }
				if ($vkeycode -eq 35) { $pos = $Items.Length - 1 }
				if ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
				if ($pos -lt 0) { $pos = 0 }
				if ($vkeycode -eq 27) { $pos = $null }
				if ($pos -ge $Items.Length) { $pos = $Items.Length - 1 }
				if ($vkeycode -ne 27) {
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
