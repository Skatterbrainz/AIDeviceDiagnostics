function Invoke-AIDiagnostics {
	<#
	.SYNOPSIS
		Invokes AI diagnostics on the local Windows or Linux system.

	.DESCRIPTION
		This function collects various system diagnostics based on the specified scope and optionally submits the data to an AI provider for analysis.

	.PARAMETER Scope
		Specifies the diagnostic areas to collect. Valid values are 'EventLog', 'Services', 'Processes', 'Registry', 'Disk', 'System'.

	.PARAMETER OutputPath
		Specifies the path to save the diagnostic results. Defaults to "$env:USERPROFILE\Documents\AIDiagnostics" on Windows and "$env:HOME/Documents/AIDiagnostics" on Linux.

	.PARAMETER ApiKey
		Specifies the API key for the AI provider.

		Store API keys in environment variables:

		$env:OPENAI_API_KEY
		$env:CLAUDE_API_KEY
		$env:GEMINI_API_KEY
		$env:AZURE_OPENAI_API_KEY
		$env:PERPLEXITY_API_KEY

	.PARAMETER SubmitPrompt
		Switch to submit the collected diagnostics to the AI provider.

	.PARAMETER CustomPrompt
		Specifies a custom prompt to submit to the AI provider.

	.PARAMETER Provider
		Specifies the AI provider to use. Valid values are 'OpenAI', 'Anthropic', 'AzureOpenAI', 'Google', 'Perplexity'.

	.PARAMETER PassThru
		Switch to return the collected diagnostics as output.

	.PARAMETER JSonOutput
		Switch to return the output in JSON format.
	.EXAMPLE
		Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -SubmitPrompt -Provider OpenAI

		Exports Eventlog and Services diagnostics to the specified output path. Then submits the collected diagnostics to OpenAI for analysis.
	.EXAMPLE
		Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -SubmitPrompt -Provider Anthropic

		Exports Eventlog and Services diagnostics to the specified output path. Then submits the collected diagnostics to Anthropic for analysis.
	.EXAMPLE
		Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -PassThru

		Exports Eventlog and Services diagnostics to the specified output path, and returns the collected diagnostics as output.
	.EXAMPLE
		Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -JSonOutput

		Exports Eventlog and Services diagnostics to the specified output path, and returns the collected diagnostics in JSON format.
	.EXAMPLE
		Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -MaxItems 50

		Exports Eventlog and Services diagnostics to the specified output path, limiting the number of items collected to 50.
	.NOTES
		Some options only work on Windows, such as collecting Registry information.
	.LINK
		https://github.com/Skatterbrainz/Nitrogen/docs/Invoke-AIDiagnostics.md
	#>
	[CmdletBinding()]
    [Alias('Invoke-AIDeviceDiagnostics')]
	param (
		[parameter(Mandatory=$true)][ValidateSet('EventLog','Services','Processes','Registry','Disk','Memory','System','Drivers','All')][string[]]$Scope,
		[parameter(Mandatory=$false)][string]$OutputPath = $(if ($IsLinux) { Join-Path $env:HOME 'Documents/Nitrogen' } else { Join-Path $env:USERPROFILE 'Documents\Nitrogen' }),
		[parameter(Mandatory=$false)][switch]$SubmitPrompt,
		[parameter(Mandatory=$false)][string]$CustomPrompt,
		[parameter(Mandatory=$false)][ValidateSet('OpenAI','Anthropic','AzureOpenAI','Google','Perplexity')][string]$Provider,
		[parameter(Mandatory=$false)][string]$ApiKey,
		[parameter(Mandatory=$false)][int]$MaxItems = 100,
		[parameter(Mandatory=$false)][switch]$PassThru,
		[parameter(Mandatory=$false)][switch]$JSonOutput
	)

	if (-not (Test-Path $OutputPath)) {
		New-Item -Path $OutputPath -ItemType Directory | Out-Null
	}
	if ($Scope -eq 'All') {
		$Scope = @('EventLog','Services','Processes','Registry','Disk','Memory','System','Drivers')
	}
	Write-Verbose "Diagnostic scopes: $($Scope -join ', ')"

	$Results = [ordered]@{}

	foreach ($Item in $Scope) {
		Write-Verbose "Processing diagnostic scope: $Item"
		switch ($Item) {
			'EventLog' {
                Write-Verbose "Collecting EventLog diagnostics for $Item"
                $Results.EventLog = get-SystemEvents -MaxItems $MaxItems
			}
			'Services' {
				$Results.Services = get-SystemServices -MaxItems $MaxItems
			}
			'Processes' {
				$Results.Processes = get-SystemProcesses -MaxItems $MaxItems
			}
			'Registry' {
				if ($IsLinux) {
					Write-Warning "Registry information is not available on Linux."
					continue
				} else {
					$Results.Registry = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
				}
			}
			'Disk' {
				$Results.Disk = Get-SystemDisks -MaxItems $MaxItems
			}
			'Memory' {
				$Results.Memory = get-SystemMemory -MaxItems $MaxItems
			}
			'System' {
                $Results.System = get-SystemSummary
			}
			'Drivers' {
				$Results.Drivers = Get-SystemDrivers -MaxItems $MaxItems
			}
		}
	}

	$JsonFile = Join-Path $OutputPath "Diagnostics.json"

	Write-Verbose "Saving diagnostics to $JsonFile"
	$Results | ConvertTo-Json -Depth 5 | Set-Content -Path $JsonFile

	if ($SubmitPrompt.IsPresent) {
		if (![string]::IsNullOrEmpty($CustomPrompt)) {
			$promptString = $CustomPrompt
		} else {
			$promptString = $script:DefaultPrompt
		}
		Write-Verbose "Using prompt: $promptString"
		switch ($Provider) {
			'OpenAI'     { Invoke-OpenAIRequest -Prompt $promptString -ApiKey $ApiKey -File $JsonFile }
			'Anthropic'  { Invoke-ClaudeRequest -Prompt $promptString -ApiKey $ApiKey -File $JsonFile }
			'AzureOpenAI'{ Invoke-AzureOpenAIRequest -Prompt $promptString -ApiKey $ApiKey -File $JsonFile }
			'Google'     { Invoke-GeminiRequest -Prompt $promptString -ApiKey $ApiKey -File $JsonFile }
			'Perplexity' { Invoke-PerplexityRequest -Prompt $promptString -ApiKey $ApiKey -File $JsonFile }
		}
	}
	if ($PassThru) {
		if ($JSonOutput) {
			$Results | ConvertTo-Json -Depth 5
		} else {
			$Results
		}
	}
}
