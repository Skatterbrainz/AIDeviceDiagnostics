function Set-NitrogenPrompt {
	<#
	.SYNOPSIS
		Creates or updates a prompt entry in Nitrogen config.
	.DESCRIPTION
		Writes prompt text under prompts.<Key> in a Nitrogen config file and optionally assigns
		that prompt key to a profile.
	.PARAMETER Key
		Prompt key name under the prompts section.
	.PARAMETER Prompt
		Prompt text value.
	.PARAMETER Scope
		Target config scope when -ConfigPath is not provided.
	.PARAMETER ConfigPath
		Explicit config path to update.
	.PARAMETER ProfileName
		Optional profile to set as using this prompt key.
	.PARAMETER CreateProfile
		Creates ProfileName when missing.
	.EXAMPLE
		Set-NitrogenPrompt -Key diagnostics.default -Prompt "Analyze diagnostics and provide actions."
	.EXAMPLE
		Set-NitrogenPrompt -Scope Local -Key diagnostics.short -Prompt "Keep output short." -ProfileName default
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Key,
		[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Prompt,
		[Parameter(Mandatory = $false)][ValidateSet('Global', 'Local')][string]$Scope = 'Global',
		[Parameter(Mandatory = $false)][string]$ConfigPath,
		[Parameter(Mandatory = $false)][string]$ProfileName,
		[Parameter(Mandatory = $false)][switch]$CreateProfile
	)

	$targetPath = if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
		$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigPath)
	}
	else {
		Get-NitrogenConfigPath -Scope $Scope
	}

	$targetDirectory = Split-Path -Path $targetPath -Parent
	if (-not (Test-Path -Path $targetDirectory -PathType Container)) {
		New-Item -Path $targetDirectory -ItemType Directory -Force | Out-Null
	}

	$config = Read-NitrogenConfigFile -Path $targetPath
	if ($config.Count -eq 0) {
		$config['version'] = 1
	}
	if (-not $config.Contains('prompts') -or $config.prompts -isnot [hashtable]) {
		$config['prompts'] = @{}
	}
	$config.prompts[$Key] = $Prompt

	if (-not [string]::IsNullOrWhiteSpace($ProfileName)) {
		if (-not $config.Contains('profiles') -or $config.profiles -isnot [hashtable]) {
			$config['profiles'] = @{}
		}
		if (-not $config.profiles.Contains($ProfileName)) {
			if (-not $CreateProfile.IsPresent) {
				throw "Profile '$ProfileName' does not exist in '$targetPath'. Use -CreateProfile to create it."
			}
			$config.profiles[$ProfileName] = @{
				provider  = 'OpenAI'
				prompt    = $Key
				providers = @{}
			}
		}
		elseif ($config.profiles[$ProfileName] -isnot [hashtable]) {
			throw "Profile '$ProfileName' in '$targetPath' is not an object."
		}
		$config.profiles[$ProfileName]['prompt'] = $Key
	}

	Test-NitrogenConfig -Config $config -Source $targetPath | Out-Null
	$config | ConvertTo-Json -Depth 20 | Set-Content -Path $targetPath -Encoding utf8
	if (-not $IsWindows) {
		$chmod = Get-Command -Name chmod -ErrorAction SilentlyContinue
		if ($null -ne $chmod) {
			& $chmod.Source 600 $targetPath
		}
	}

	[pscustomobject]@{
		ConfigPath  = $targetPath
		PromptKey   = $Key
		ProfileName = $ProfileName
	}
}
