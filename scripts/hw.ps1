function Get-RAMType {
	param (
		[string]$Type
	)

	switch ($Type) {
		0 { return "Unknown" }
		2 { return "DRAM" }
		3 { return "Synchronous DRAM" }
		4 { return "Cache DRAM" }
		5 { return "EDO" }
		6 { return "EDRAM" }
		7 { return "VRAM" }
		8 { return "SRAM" }
		9 { return "RAM" }
		10 { return "ROM" }
		11 { return "Flash" }
		12 { return "EEPROM" }
		13 { return "FEPROM" }
		14 { return "EPROM" }
		15 { return "CDRAM" }
		16 { return "3DRAM" }
		17 { return "SDRAM" }
		18 { return "SGRAM" }
		19 { return "RDRAM" }
		20 { return "DDR" }
		21 { return "DDR2" }
		22 { return "DDR2 FB-DIMM" }
		24 { return "DDR3" }
		25 { return "FBD2" }
		26 { return "DDR4" }
		default { return "Unknown by Script" }
	}
}

#system
$system = Get-CimInstance CIM_ComputerSystem
$os = Get-CimInstance CIM_OperatingSystem
"System:"
"- Name: " + $system.Name
"- Manufacturer: " + $system.Manufacturer
Write-Host "- Model: " -NoNewline
Write-Host $system.Model -ForegroundColor DarkCyan
"- OS: $($os.caption), Service Pack: $($os.ServicePackMajorVersion)"

#motherboard
$board = Get-CimInstance -ClassName Win32_BaseBoard
Write-Host "Motherboard: " -NoNewline
Write-Host $board.Manufacturer $board.Product -ForegroundColor DarkCyan

#cpu
$cpus = Get-CimInstance CIM_Processor
Write-Host "CPU: "
foreach ($cpu in $cpus) {
	Write-Host "- " -NoNewline
	Write-Host $cpu.Name -ForegroundColor DarkCyan -NoNewline
	" (cores $($cpu.NumberOfCores)/$($cpu.NumberOfLogicalProcessors))"
}

#ram
$rams = Get-CimInstance -ClassName Win32_PhysicalMemory
"RAM: "
"- Capacity: {0:N2} GiB" -f (($rams.Capacity | Measure-Object -Sum).Sum / 1GB)
"- Total Physical Memory: {0:N2} GiB" -f ($system.TotalPhysicalMemory / 1GB)
"- Memory modelus: "
foreach ($ram in $rams) {
	"  - $((Get-RAMType -Type $ram.SMBIOSMemoryType)) [$($ram.BankLabel)/$($ram.DeviceLocator)] ({0:N2} GiB) ($($ram.Speed) Hz)" -f ($ram.Capacity / 1GB)
}

#gpu
$gpus = Get-CimInstance -ClassName Win32_VideoController
"GPU:"
foreach ($gpu in $gpus) {
	Write-Host "- " -NoNewline
	Write-Host $gpu.Caption -ForegroundColor DarkCyan
}

#storage
$disks = Get-Disk
"Storage:"
foreach ($disk in $disks) {
	Write-Host "- " -NoNewline
	Write-Host $disk.FriendlyName -ForegroundColor DarkCyan -NoNewline
	" ({0:N2} GiB)" -f ($disk.Size / 1GB) 
}

#volumes
"- Volumes: "
$volumes = Get-Volume
foreach ($vol in $volumes) {
	"  - Volume ($($vol.FileSystemLabel)): "
	if (!($null -eq $vol.DriveLetter)) {
		"    - DriveLetter: $($vol.DriveLetter)"
	}

	"    - Capacity: {0:N2} GiB" -f ($vol.Size / 1GB)
	"    - Free Space: {0:P2} ({1:N2} GiB)" -f ($vol.SizeRemaining / $vol.Size), ($vol.SizeRemaining / 1GB)
}
