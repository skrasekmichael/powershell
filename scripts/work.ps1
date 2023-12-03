$workspace = ".workspace"
$autorun = "$workspace/autorun.ps1"
$workspaceFile = "$env:USERPROFILE/.workspace-list"

$workspaceList = New-Object Collections.Generic.List[string]
$names = New-Object Collections.Generic.List[string]
$dirs = New-Object Collections.Generic.List[string]

if (Test-Path -Path $workspaceFile) {
	$content = Get-Content $workspaceFile -Raw
	$enumerator = (ConvertFrom-StringData -StringData $content).GetEnumerator()
	while ($null -ne $enumerator -and $enumerator.MoveNext()) {
		$var = $enumerator.Current
		$names.Add($var.Name) | Out-Null
		$dirs.Add($var.Value) | Out-Null
		$workspaceList.Add("$($var.Name)=$($var.Value)") | Out-Null
	}
} else {
	Write-Host >$workspaceFile
}


if ("" -eq $args -or $args[0] -eq "select") {
	$index = Menu -Items @($names) -ReturnIndex
	if ($null -ne $index) {
		echo $dirs[$index]
		Set-Location $dirs[$index]
		$host.UI.RawUI.WindowTitle = $names[$index]

		if (Test-Path $autorun ) {
			&$autorun
		}
	}
} elseif ($args[0] -eq "create") {
	while ($true) {
		$name = Read-Host "Enter workspace name"
		if ($names.Contains($name)) {
			Write-Host "Name [$name] already exist."
		} else {
			break
		}
	}

	Write-Host "Creating workspace for $pwd ..."
	$path = $pwd.Path.Replace("\", "/")
	$workspaceList.Add("$name=$path") | Out-Null
	$workspaceList | Out-File $workspaceFile
	
	$choices = "&Yes", "&No"
	$decision = $Host.UI.PromptForChoice("Create autorun script?", "Do you want to create script, which will automatically run after workspace switch?", $choices, 1)
	if ($decision -eq 0) {
		if (-not (Test-Path $workspace)) {
			mkdir $workspace
		}

		if (-not (Test-Path $autorun )) {
			Write-Host >$autorun
		}

		Invoke-Item	$autorun
	}
} elseif ($args[0] -eq "remove") {
	$index = Menu -Items @($names) -ReturnIndex
	if ($index -ne -1) {
		$choices = "&Yes", "&No"
		$decision = $Host.UI.PromptForChoice("Remove workspace?", "Do you want to remove workspace [$($names[$index])]?", $choices, 1)
		if ($decision -eq 0) {
			$workspaceList.RemoveAt($index) | Out-Null
			$workspaceList | Out-File $workspaceFile
		}
	}
} elseif ($args[0] -eq "edit") {
	nano $workspaceFile
} else {
	Write-Error "Bad parameters"
}
