$workspace = ".workspace"
$autorun = "$workspace/autorun.ps1"
$workspaceFile = "$env:USERPROFILE/.workspace-list"

$workspaceList = New-Object Collections.Generic.List[psobject]

function Read-WorskapceList {
	$data = Import-Csv $workspaceFile -Header "Name", "Location", "Timestamp" -Delimiter ";"
	return $data | Sort-Object -Property { [System.DateTime]::ParseExact($_.Timestamp, "dd.MM.yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture) } -Descending
}

function Save-WorkspaceList {
	$workspaceList | Export-Csv -Path $workspaceFile -Delimiter ";" -NoHeader
}

if (Test-Path -Path $workspaceFile) {
	$workspaceList = [Collections.Generic.List[psobject]](Read-WorskapceList)
} else {
	Write-Host >$workspaceFile
}

if ("" -eq $args -or $args[0] -eq "select") {
	$index = Menu -Items @($workspaceList.Name) -ReturnIndex
	if ($null -ne $index) {
		$workspaceList[$index].Timestamp = (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")
		Save-WorkspaceList

		Write-Host $workspaceList[$index].Location
		Set-Location $workspaceList[$index].Location
		$host.UI.RawUI.WindowTitle = $workspaceList[$index].Name

		if (Test-Path $autorun ) {
			&$autorun
		}
	}
} elseif ($args[0] -eq "create") {
	$path = $pwd.Path.Replace("\", "/")
	if ($workspaceList | Where-Object { $_.Location -eq $path }) {
		Write-Error "Workspace for [$path] already exists."
		return
	}

	while ($true) {
		$name = Read-Host "Enter workspace name"
		if ($workspaceList | Where-Object { $_.Name -eq $name }) {
			Write-Host "Workspace with name [$name] already exists."
		} else {
			break
		}
	}

	Write-Host "Creating workspace for $pwd ..." -NoNewline
	$workspaceList.Add([PSCustomObject]@{ 
		Name = $name;
		Location = $path;
		Timestamp = (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")
	}) | Out-Null
	Save-WorkspaceList
	Write-Host "DONE"

	$choices = "&Yes", "&No"
	$decision = $Host.UI.PromptForChoice("Create autorun script?", "Do you want to create a powershell script, which will automatically run after a workspace switch?", $choices, 1)
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
	$index = Menu -Items @($workspaceList.Name) -ReturnIndex
	if ($index -ne -1) {
		$choices = "&Yes", "&No"
		$decision = $Host.UI.PromptForChoice("Remove workspace?", "Do you want to remove workspace [$($workspaceList[$index].Name)]?", $choices, 1)
		if ($decision -eq 0) {
			$workspaceList.RemoveAt($index)
			Save-WorkspaceList
		}
	}
} elseif ($args[0] -eq "edit") {
	nano $workspaceFile
} else {
	Write-Error "Bad parameters"
}
