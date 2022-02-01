if ((Get-Host).Version.Major -gt 5) {
	Import-Module -Name Terminal-Icons

	if ($host.Name -eq "ConsoleHost") {
		Import-Module PSReadLine
	}

	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -EditMode Windows

	Set-Alias -Name ren -Value Rename-Item
}

Set-Alias -Name zip -Value Compress-Archive
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name new -Value New-Terminal
Set-Alias -Name refresh -Value Invoke-RefreshEnviromentVariables

Set-PSReadLineKeyHandler -Key Alt+e `
	-BriefDescription CWD `
	-LongDescription "Open the current working directory in the Windows Explorer" `
	-ScriptBlock { &explorer.exe . }

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)
	dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
	}
}

function Write-BranchName {
	git status | Out-Null
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

function New-Terminal($arg) {
	if (($arg -eq "split") -or ($arg -eq "s")) {
		wt sp -d "$pwd"
	} elseif (($arg -eq "tab") -or ($arg -eq "t")) {
		wt nt -d "$pwd"
	}
}

function Invoke-RefreshEnviromentPath {
	[System.Environment]::SetEnvironmentVariable("PATH", 
	[System.Environment]::GetEnvironmentVariable("PATH", "machine") + ";" +
	[System.Environment]::GetEnvironmentVariable("PATH", "user"))
}

function Invoke-RefreshEnviromentVariables {
	$tmp = $env:TMP + "\.enviroment_variables.tmp"
	Start-Process pwsh -ArgumentList "-NoProfile -Command &{ Get-Item -Path env:* | % { Write-Host `$_.Name -NoNewline; Write-Host `"=`" -NoNewline; Write-Host `$_.Value } }" -NoNewWindow -RedirectStandardOutput $tmp -UseNewEnvironment -Wait

	foreach ($var in Get-Content $tmp | ConvertFrom-String -PropertyNames "Name", "Value" -Delimiter "=") {
		[System.Environment]::SetEnvironmentVariable($var.Name, $var.Value)
	}

	Remove-Item $tmp
	Invoke-RefreshEnviromentPath
}

function prompt {
	#username@address
	$address = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi).IPAddress
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

Invoke-RefreshEnviromentPath
