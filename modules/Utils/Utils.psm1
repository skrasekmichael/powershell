function Format-Size {
	param (
		[double]$Size
	)

	$units = "B", "KiB", "MiB", "GiB", "TiB"
	$tmp = $Size
	$index = 0;
	while (1) {
		if ($tmp -lt 1024) {
			break
		}
		$tmp /= 1024
		$index++;
	}

	$pso = New-Object psobject -Property @{
		Value = $Size;
		Formatted = ($tmp.ToString("#.##") + " " + $units[$index])
	}

	$pso | Add-Member scriptmethod ToString { 
		$this.Formatted
	} -force

	return $pso
}

Export-ModuleMember -Function Format-Size
