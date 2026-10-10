('private','public') | Foreach-Object {
	Get-ChildItem -Path $(Join-Path -Path $PSScriptRoot -ChildPath $_) -Filter "*.ps1" | Foreach-Object { write-verbose $_.FullName; . $_.FullName }
}

$script:DefaultPrompt = @"
Analyze the following Windows diagnostic data and provide a summary of the findings:
1. Rate findings by severity High, Medium, Low
2. Provide recommendations for each finding based on its severity
3. Keep responses concise and focused on actionable insights
4. Categorize by type of finding (e.g., EventLog, Services, Processes, Registry, Disk, Memory, System)
5. Provide URL links to relevant documentation for each recommendation
6. Result should be returned in JSON format: Finding, TimeStamp, Severity, Category, Recommendation, DocumentationURL
$JsonFile
"@

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