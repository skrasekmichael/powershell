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

	$workspaceList.Add([PSCustomObject]@{ 
		Name = $name;
		Location = $path;
		Timestamp = (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")
	}) | Out-Null
	Save-WorkspaceList

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
