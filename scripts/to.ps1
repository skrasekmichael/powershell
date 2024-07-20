param (
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Shortcut")]
	[ValidateSet("d", "prog", "dw", "data", "fit", IgnoreCase = $true)]
	[string]$Shortcut
)

switch ($Shortcut) {
	"" {
		Write-Host "prog|dw|d|data|fit"
	}
	"d" {
		Set-Location "C:\Users\skras\OneDrive\Desktop"
	}
	"prog" {  
		Set-Location "D:\prog"
	}
	"dw" {
		Set-Location "D:\downloads"
	}
	"data" {
		Set-Location "D:\data"
	}
	"fit" {
		Set-Location "D:\data\fit\MITAI"
	}
	default {
		Write-Error "Unexisting shortcut"
	}
}

