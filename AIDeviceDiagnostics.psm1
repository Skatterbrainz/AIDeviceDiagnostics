('private','public') | Foreach-Object {
	Get-ChildItem -Path $(Join-Path -Path $PSScriptRoot -ChildPath $_) -Filter "*.ps1" | Foreach-Object { write-verbose $_.FullName; . $_.FullName }
}

if ($IsLinux) {
	Write-Host "Running on a Linux system."
	if (!(Get-Module -Name linuxtools -ListAvailable)) {
		Write-Warning "The 'linuxtools' module is not installed. Some Linux-specific diagnostics may not be available."
	}
} elseif ($IsMacOS) {
	Write-Host "Running on a macOS system."
	if (!(Get-Module -Name linuxtools -ListAvailable)) {
		Write-Warning "The 'linuxtools' module is not installed. Some macOS-specific diagnostics may not be available."
	}
} else {
	Write-Host "Running on a Windows system."
}