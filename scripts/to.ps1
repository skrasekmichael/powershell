switch ($args[0]) {
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
		Set-Location "D:\data\fit"
	}
	default {
		Write-Error "Unexisting shortcut"
	}
}

