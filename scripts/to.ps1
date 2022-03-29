switch ($args[0]) {
	"" {
		Write-Host "prog|c#|php|cmd|dw|d|data|fit"
	}
	"d" {
		Set-Location "C:\Users\skras\OneDrive\Desktop"
	}
	"prog" {  
		Set-Location "D:\prog"
	}
	"c#" {
		Set-Location "D:\prog\dotnet"
	}
	"php" {
		Set-Location "C:\xampp\htdocs\projects"
	}
	"cmd" {
		Set-Location "C:\ProgramData\Microsoft\Windows\Start Menu\commands"
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

