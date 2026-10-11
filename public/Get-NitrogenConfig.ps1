function Get-NitrogenConfig {
	<#
	.SYNOPSIS
		Reads Nitrogen configuration.
	.DESCRIPTION
		Reads Nitrogen configuration from global, local, effective merged, or explicit config path.
	.PARAMETER Scope
		Configuration scope. Effective returns merged global+local config.
	.PARAMETER ConfigPath
		Explicit config file path to read.
	.PARAMETER AsHashtable
		Returns configuration as a hashtable instead of a PSCustomObject.
	.EXAMPLE
		Get-NitrogenConfig
	.EXAMPLE
		Get-NitrogenConfig -Scope Local
	.EXAMPLE
		Get-NitrogenConfig -ConfigPath ./config/nitrogen.json
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)][ValidateSet('Global', 'Local', 'Effective')][string]$Scope = 'Effective',
		[Parameter(Mandatory = $false)][string]$ConfigPath,
		[Parameter(Mandatory = $false)][switch]$AsHashtable
	)

	$config = $null
	if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
		$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigPath)
		$config = Read-NitrogenConfigFile -Path $resolvedPath
		Test-NitrogenConfig -Config $config -Source $resolvedPath | Out-Null
	}
	elseif ($Scope -eq 'Effective') {
		$config = Get-NitrogenEffectiveConfig
	}
	else {
		$path = Get-NitrogenConfigPath -Scope $Scope
		$config = Read-NitrogenConfigFile -Path $path
		Test-NitrogenConfig -Config $config -Source $path | Out-Null
	}

	if ($AsHashtable.IsPresent) {
		return $config
	}
	return ($config | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
}
