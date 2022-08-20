if ((Get-Host).Version.Major -gt 5) {
	Import-Module Terminal-Icons
	Import-Module posh-git

	if ($host.Name -eq "ConsoleHost") {
		Import-Module PSReadLine
	}

	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -EditMode Windows

	Set-Alias -Name ren -Value Rename-Item
	Set-Alias -Name wget -Value Invoke-WebRequest
}

Set-Alias -Name zip -Value Compress-Archive
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name new -Value New-Terminal
Set-Alias -Name refresh -Value Invoke-RefreshEnviromentVariables
Set-Alias -Name mklink -Value New-Symlink

$esc = [char]27

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
		[System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
	}
}

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)
	dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
	}
}

function Write-BranchName {
	param(
		[System.Text.StringBuilder]$StringBuilder
	)

	$branch = git rev-parse --abbrev-ref HEAD 2>$null
	if ($LASTEXITCODE -eq 0) {
		if ($branch -eq "HEAD") {
			$branch = git rev-parse --short HEAD
			$StringBuilder.Append("$esc[91m($branch) ")
		} else {
			$StringBuilder.Append("$esc[94m($branch) ")
		}
	}
}

function New-Terminal($arg) {
	if (($arg -eq "split") -or ($arg -eq "s")) {
		wt sp -d "$pwd"
	} elseif (($arg -eq "tab") -or ($arg -eq "t") -or ($null -eq $arg)) {
		wt nt -d "$pwd"
	}
}

function New-Symlink {
	param(
		[string]$TargetPath,
		[string]$LinkPath
	)
	New-Item -Path $LinkPath -ItemType SymbolicLink -Value $TargetPath
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

function Get-LastError {
	$Error[0].Exception | Format-List * -Force
}

function prompt {
	$sb = [System.Text.StringBuilder]::new(300)

	#username@address
	$address = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi).IPAddress
	$sb.Append("$esc[92m$env:USERNAME@$address") | Out-Null

	#directory
	$sb.Append("$esc[39m $PWD ") | Out-Null

	#git branch
	Write-BranchName -StringBuilder $sb | Out-Null
	
	#powershell version
	$ver = $PSVersionTable.PSVersion
	$sb.Append("$esc[96m$($ver.Major).$($ver.Minor)") | Out-Null

	#admin rights
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		$sb.Append("$esc[91m#`e[39m") | Out-Null
	} else {
		$sb.Append("$esc[39m>") | Out-Null
	}

	return $sb.ToString()
}

Invoke-RefreshEnviromentPath
