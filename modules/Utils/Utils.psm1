function Format-Size {
	param (
		[double]$Size
	)

	$units = "B", "KiB", "MiB", "GiB", "TiB"
	$tmp = $Size
	$index = 0
	while ($tmp -ge 1024) {
		$tmp /= 1024
		$index++;
	}

	$pso = New-Object psobject -Property @{
		Value = $Size
		Formatted = ($tmp.ToString("0.##") + " " + $units[$index])
	}

	$pso | Add-Member scriptmethod ToString {
		$this.Formatted
	} -force

	return $pso
}

function Format-Double {
	param (
		[double]$Value,
		[string]$Before,
		[string]$After
	)

	$pso = New-Object psobject -Property @{
		Value = $Value
		Formatted = ($Before + $Value.ToString("0.##") + $After)
	}

	$pso | Add-Member scriptmethod ToString {
		$this.Formatted
	} -force

	return $pso
}

function Format-bps {
	param (
		[double]$Value
	)

	$units = "bps", "Kbps", "Mbps"
	$tmp = $Value
	$index = 0
	while ($tmp -ge 1000) {
		$tmp /= 1000
		$index++;
	}

	$pso = New-Object psobject -Property @{
		Value = $Value
		Formatted = ($tmp.ToString("0.##") + " " + $units[$index])
	}

	$pso | Add-Member scriptmethod ToString {
		$this.Formatted
	} -force

	return $pso
}

Export-ModuleMember -Function Format-Size
Export-ModuleMember -Function Format-Double
Export-ModuleMember -Function Format-bps
