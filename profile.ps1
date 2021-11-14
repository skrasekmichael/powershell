if ((Get-Host).Version.Major -gt 5) {
	Import-Module -Name Terminal-Icons

	if ($host.Name -eq "ConsoleHost") {
		Import-Module PSReadLine
	}

	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -EditMode Windows
}

function Write-BranchName {
	&git status 1> $null 6> $null
	if ($LASTEXITCODE -eq "0") {
		try {
			$branch = git rev-parse --abbrev-ref HEAD
			if ($branch -eq "HEAD") {
				$branch = git rev-parse --short HEAD
				Write-Host "($branch) " -NoNewline -ForegroundColor Red
			} else {
				Write-Host "($branch) " -NoNewline -ForegroundColor Blue
			}
		} catch {
			Write-Host "(no branches yet) " -NoNewline -ForegroundColor Yellow
		}
	}
}

function prompt {
	#username@address
	$address = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlia Wi-Fi).IPAddress
	Write-Host "$env:USERNAME@$address" -NoNewline -ForegroundColor Green
	
	#directory
	Write-Host " $PWD " -NoNewline

	#git branch
	Write-BranchName
	
	#powershell version
	$ver = (Get-Host).Version
	Write-Host "$($ver.Major).$($ver.Minor)" -NoNewline -ForegroundColor Cyan

	#admin rights
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		return "`e[91m#`e[39m"
	} else {
		return ">"
	}
}
