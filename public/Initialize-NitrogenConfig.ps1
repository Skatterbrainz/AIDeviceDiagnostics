function Initialize-NitrogenConfig {
	<#
	.SYNOPSIS
		Creates a starter Nitrogen configuration file.
	.DESCRIPTION
		Writes a starter config.json for Nitrogen, including provider defaults and prompt mapping.
		Optionally configures SecretStore and prompts to set provider API keys using SecretManagement.
	.PARAMETER Scope
		Target config scope when -ConfigPath is not provided. Valid values: Global, Local.
	.PARAMETER ConfigPath
		Explicit path for the config file. Overrides -Scope.
	.PARAMETER ProfileName
		Profile name to create in the config.
	.PARAMETER Provider
		Default provider for the generated profile.
	.PARAMETER PromptKey
		Prompt key name to store under prompts.
	.PARAMETER PromptText
		Prompt text associated with PromptKey.
	.PARAMETER MaxItems
		Default max item limit to set in config defaults.
	.PARAMETER Force
		Overwrite existing config file.
	.PARAMETER ConfigureSecretVault
		Attempts to register SecretStore as default vault when available.
	.PARAMETER SetSecrets
		Interactively prompts for provider API keys and stores them by apiKeyRef.
	.EXAMPLE
		Initialize-NitrogenConfig
	.EXAMPLE
		Initialize-NitrogenConfig -Scope Local -ProfileName work -Provider Anthropic
	.EXAMPLE
		Initialize-NitrogenConfig -ConfigureSecretVault -SetSecrets
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)][ValidateSet('Global', 'Local')][string]$Scope = 'Global',
		[Parameter(Mandatory = $false)][string]$ConfigPath,
		[Parameter(Mandatory = $false)][string]$ProfileName = 'default',
		[Parameter(Mandatory = $false)][ValidateSet('OpenAI', 'Anthropic', 'AzureOpenAI', 'Google', 'Perplexity')][string]$Provider = 'OpenAI',
		[Parameter(Mandatory = $false)][string]$PromptKey = 'diagnostics.default',
		[Parameter(Mandatory = $false)][string]$PromptText = 'Analyze diagnostics and return concise, actionable findings.',
		[Parameter(Mandatory = $false)][ValidateRange(1, 5000)][int]$MaxItems = 100,
		[Parameter(Mandatory = $false)][switch]$Force,
		[Parameter(Mandatory = $false)][switch]$ConfigureSecretVault,
		[Parameter(Mandatory = $false)][switch]$SetSecrets
	)

	if ([string]::IsNullOrWhiteSpace($ProfileName)) {
		throw "ProfileName cannot be empty."
	}
	if ([string]::IsNullOrWhiteSpace($PromptKey)) {
		throw "PromptKey cannot be empty."
	}

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
	if ((Test-Path -Path $targetPath -PathType Leaf) -and -not $Force.IsPresent) {
		throw "Config file already exists at '$targetPath'. Use -Force to overwrite."
	}

	$providers = @{
		OpenAI = @{
			endpoint      = 'https://api.openai.com/v1/responses'
			filesEndpoint = 'https://api.openai.com/v1/files'
			model         = 'gpt-5'
			apiKeyRef     = "nitrogen/$ProfileName/openai/api_key"
		}
		Anthropic = @{
			endpoint      = 'https://api.anthropic.com/v1/messages'
			filesEndpoint = 'https://api.anthropic.com/v1/files'
			model         = 'claude-sonnet-5-5'
			apiVersion    = '2023-06-01'
			maxTokens     = 1024
			apiKeyRef     = "nitrogen/$ProfileName/anthropic/api_key"
		}
		AzureOpenAI = @{
			endpoint     = 'https://<resource>.openai.azure.com'
			deploymentId = 'gpt-5-prod'
			model        = 'gpt-5'
			apiKeyRef    = "nitrogen/$ProfileName/azureopenai/api_key"
		}
		Google = @{
			endpoint      = 'https://generativelanguage.googleapis.com/v1beta'
			filesEndpoint = 'https://generativelanguage.googleapis.com/v1beta/files'
			model         = 'gemini-3.5-flash'
			apiKeyRef     = "nitrogen/$ProfileName/google/api_key"
		}
		Perplexity = @{
			endpoint  = 'https://api.perplexity.ai/chat/completions'
			model     = 'sonar-pro'
			apiKeyRef = "nitrogen/$ProfileName/perplexity/api_key"
		}
	}

	$config = @{
		version  = 1
		defaults = @{
			profile  = $ProfileName
			provider = $Provider
			maxItems = $MaxItems
		}
		profiles = @{
			$ProfileName = @{
				provider  = $Provider
				prompt    = $PromptKey
				maxItems  = $MaxItems
				providers = $providers
			}
		}
		prompts  = @{
			$PromptKey = $PromptText
		}
	}

	$config | ConvertTo-Json -Depth 15 | Set-Content -Path $targetPath -Encoding utf8
	if (-not $IsWindows) {
		$chmod = Get-Command -Name chmod -ErrorAction SilentlyContinue
		if ($null -ne $chmod) {
			& $chmod.Source 600 $targetPath
		}
	}

	$vaultConfigured = $false
	if ($ConfigureSecretVault.IsPresent) {
		$registerSecretVault = Get-Command -Name Register-SecretVault -ErrorAction SilentlyContinue
		$getSecretVault = Get-Command -Name Get-SecretVault -ErrorAction SilentlyContinue
		if ($null -eq $registerSecretVault -or $null -eq $getSecretVault) {
			Write-Warning "SecretManagement commands are unavailable. Install Microsoft.PowerShell.SecretManagement and Microsoft.PowerShell.SecretStore."
		}
		else {
			$secretStoreVault = Get-SecretVault -Name 'SecretStore' -ErrorAction SilentlyContinue
			if ($null -eq $secretStoreVault) {
				Register-SecretVault -Name 'SecretStore' -ModuleName 'Microsoft.PowerShell.SecretStore' -DefaultVault -ErrorAction Stop
			}
			$vaultConfigured = $true
		}
	}

	$secretsSet = 0
	if ($SetSecrets.IsPresent) {
		$setSecret = Get-Command -Name Set-Secret -ErrorAction SilentlyContinue
		if ($null -eq $setSecret) {
			throw "Set-Secret is unavailable. Install Microsoft.PowerShell.SecretManagement and register a vault before using -SetSecrets."
		}
		foreach ($providerName in @('OpenAI', 'Anthropic', 'AzureOpenAI', 'Google', 'Perplexity')) {
			$providerConfig = $providers[$providerName]
			$secretName = $providerConfig.apiKeyRef
			$secureValue = Read-Host "Enter API key for $providerName (leave blank to skip)" -AsSecureString
			$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureValue)
			try {
				$plainValue = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
			}
			finally {
				[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
			}
			if ([string]::IsNullOrWhiteSpace($plainValue)) {
				continue
			}
			Set-Secret -Name $secretName -Secret $secureValue -ErrorAction Stop
			$secretsSet++
		}
	}

	[pscustomobject]@{
		ConfigPath      = $targetPath
		Profile         = $ProfileName
		DefaultProvider = $Provider
		SecretVault     = if ($vaultConfigured) { 'Configured' } else { 'NotChanged' }
		SecretsStored   = $secretsSet
	}
}
