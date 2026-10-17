function Get-NitrogenMemberValue {
	param (
		[Parameter(Mandatory = $false)]$InputObject,
		[Parameter(Mandatory = $true)][string]$Name
	)
	if ($null -eq $InputObject) {
		return $null
	}
	if ($InputObject -is [System.Collections.IDictionary]) {
		if ($InputObject.Contains($Name)) {
			return $InputObject[$Name]
		}
		return $null
	}
	$prop = $InputObject.PSObject.Properties[$Name]
	if ($null -ne $prop) {
		return $prop.Value
	}
	return $null
}

function ConvertTo-NitrogenHashtable {
	param (
		[Parameter(Mandatory = $true)]$InputObject
	)
	if ($null -eq $InputObject) {
		return $null
	}
	if ($InputObject -is [System.Collections.IDictionary]) {
		$result = @{}
		foreach ($key in $InputObject.Keys) {
			$result[$key] = ConvertTo-NitrogenHashtable -InputObject $InputObject[$key]
		}
		return $result
	}
	if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
		$list = New-Object System.Collections.ArrayList
		foreach ($item in $InputObject) {
			[void]$list.Add((ConvertTo-NitrogenHashtable -InputObject $item))
		}
		return @($list)
	}
	if ($InputObject -is [psobject] -and $InputObject.PSObject.Properties.Count -gt 0) {
		$result = @{}
		foreach ($property in $InputObject.PSObject.Properties) {
			$result[$property.Name] = ConvertTo-NitrogenHashtable -InputObject $property.Value
		}
		return $result
	}
	return $InputObject
}

function Merge-NitrogenHashtable {
	param (
		[Parameter(Mandatory = $true)][hashtable]$Base,
		[Parameter(Mandatory = $true)][hashtable]$Overlay
	)
	$merged = @{}
	foreach ($key in $Base.Keys) {
		$merged[$key] = $Base[$key]
	}
	foreach ($key in $Overlay.Keys) {
		$baseValue = Get-NitrogenMemberValue -InputObject $merged -Name $key
		$overlayValue = $Overlay[$key]
		if ($baseValue -is [hashtable] -and $overlayValue -is [hashtable]) {
			$merged[$key] = Merge-NitrogenHashtable -Base $baseValue -Overlay $overlayValue
			continue
		}
		$merged[$key] = $overlayValue
	}
	return $merged
}

function Get-NitrogenConfigPath {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)][ValidateSet('Global', 'Local')][string]$Scope = 'Global'
	)
	if ($Scope -eq 'Local') {
		return (Join-Path -Path (Get-Location).Path -ChildPath '.nitrogen/config.json')
	}
	$homePath = if ($IsWindows) { $env:USERPROFILE } else { $env:HOME }
	if ([string]::IsNullOrWhiteSpace($homePath)) {
		throw "Unable to determine a home directory for global Nitrogen config path."
	}
	return (Join-Path -Path $homePath -ChildPath '.nitrogen/config.json')
}

function Read-NitrogenConfigFile {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][string]$Path
	)
	if (-not (Test-Path -Path $Path -PathType Leaf)) {
		return @{}
	}
	try {
		$content = Get-Content -Path $Path -Raw -ErrorAction Stop
		if ([string]::IsNullOrWhiteSpace($content)) {
			return @{}
		}
		$parsed = $content | ConvertFrom-Json -ErrorAction Stop
		$result = ConvertTo-NitrogenHashtable -InputObject $parsed
		if ($result -isnot [hashtable]) {
			throw "Configuration root must be a JSON object."
		}
		return $result
	}
	catch {
		throw "Failed to parse config file '$Path': $($_.Exception.Message)"
	}
}

function Test-NitrogenConfig {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][hashtable]$Config,
		[Parameter(Mandatory = $true)][string]$Source
	)
	$version = Get-NitrogenMemberValue -InputObject $Config -Name 'version'
	if ($null -ne $version -and [int]$version -ne 1) {
		throw "Unsupported config version '$version' in '$Source'. Supported version is 1."
	}
	$profiles = Get-NitrogenMemberValue -InputObject $Config -Name 'profiles'
	if ($null -eq $profiles) {
		return $true
	}
	if ($profiles -isnot [hashtable]) {
		throw "Invalid config in '$Source': 'profiles' must be an object."
	}
	$prompts = Get-NitrogenMemberValue -InputObject $Config -Name 'prompts'
	foreach ($profileName in $profiles.Keys) {
		$profileConfig = $profiles[$profileName]
		if ($profileConfig -isnot [hashtable]) {
			throw "Invalid config in '$Source': profile '$profileName' must be an object."
		}
		$promptRef = Get-NitrogenMemberValue -InputObject $profileConfig -Name 'prompt'
		if (-not [string]::IsNullOrWhiteSpace($promptRef)) {
			if ($prompts -isnot [hashtable] -or -not $prompts.Contains($promptRef)) {
				throw "Invalid config in '$Source': profile '$profileName' references unknown prompt '$promptRef'."
			}
		}
		$providers = Get-NitrogenMemberValue -InputObject $profileConfig -Name 'providers'
		if ($null -eq $providers) {
			continue
		}
		if ($providers -isnot [hashtable]) {
			throw "Invalid config in '$Source': profile '$profileName' providers must be an object."
		}
		foreach ($providerName in $providers.Keys) {
			$providerConfig = $providers[$providerName]
			if ($providerConfig -isnot [hashtable]) {
				throw "Invalid config in '$Source': provider '$providerName' in profile '$profileName' must be an object."
			}
			if ($providerConfig.Contains('apiKey')) {
				throw "Invalid config in '$Source': provider '$providerName' in profile '$profileName' uses plaintext 'apiKey'. Use 'apiKeyRef', environment variables, or -ApiKey."
			}
			$endpoint = Get-NitrogenMemberValue -InputObject $providerConfig -Name 'endpoint'
			if (-not [string]::IsNullOrWhiteSpace($endpoint)) {
				if ($endpoint -match '<[^>]+>') {
					continue
				}
				$uri = $null
				if (-not [Uri]::TryCreate($endpoint, [UriKind]::Absolute, [ref]$uri)) {
					throw "Invalid config in '$Source': provider '$providerName' in profile '$profileName' has invalid endpoint '$endpoint'."
				}
				# Ollama is typically hosted on-premises and serves plain http by default.
				$allowedSchemes = if ($providerName -eq 'Ollama') { @('http', 'https') } else { @('https') }
				if ($uri.Scheme -notin $allowedSchemes) {
					$schemeHint = if ($providerName -eq 'Ollama') { 'http or https' } else { 'https' }
					throw "Invalid config in '$Source': provider '$providerName' in profile '$profileName' endpoint must use $schemeHint."
				}
			}
		}
	}
	return $true
}

function Get-NitrogenEffectiveConfig {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)][string]$ConfigPath
	)
	$globalPath = Get-NitrogenConfigPath -Scope Global
	$localPath = Get-NitrogenConfigPath -Scope Local

	$config = @{}
	$config = Merge-NitrogenHashtable -Base $config -Overlay (Read-NitrogenConfigFile -Path $globalPath)
	$config = Merge-NitrogenHashtable -Base $config -Overlay (Read-NitrogenConfigFile -Path $localPath)

	if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
		$customResolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigPath)
		$config = Merge-NitrogenHashtable -Base $config -Overlay (Read-NitrogenConfigFile -Path $customResolvedPath)
	}

	Test-NitrogenConfig -Config $config -Source "effective configuration" | Out-Null
	return $config
}

function Resolve-NitrogenProfileConfig {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][hashtable]$Config,
		[Parameter(Mandatory = $false)][string]$Profile
	)
	$defaults = Get-NitrogenMemberValue -InputObject $Config -Name 'defaults'
	$defaultProfile = Get-NitrogenMemberValue -InputObject $defaults -Name 'profile'
	$resolvedProfile = if (-not [string]::IsNullOrWhiteSpace($Profile)) { $Profile } elseif (-not [string]::IsNullOrWhiteSpace($defaultProfile)) { $defaultProfile } else { 'default' }

	$profiles = Get-NitrogenMemberValue -InputObject $Config -Name 'profiles'
	if ($profiles -isnot [hashtable] -or -not $profiles.Contains($resolvedProfile)) {
		if (-not [string]::IsNullOrWhiteSpace($Profile) -or ($profiles -is [hashtable] -and $profiles.Keys.Count -gt 0)) {
			$available = if ($profiles -is [hashtable]) { ($profiles.Keys -join ', ') } else { '<none>' }
			throw "Profile '$resolvedProfile' was not found in config. Available profiles: $available"
		}
		return [pscustomobject]@{
			Name   = $resolvedProfile
			Config = @{}
		}
	}
	return [pscustomobject]@{
		Name   = $resolvedProfile
		Config = $profiles[$resolvedProfile]
	}
}

function Resolve-NitrogenProviderConfig {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][hashtable]$ProfileConfig,
		[Parameter(Mandatory = $false)][string]$Provider
	)
	$providers = Get-NitrogenMemberValue -InputObject $ProfileConfig -Name 'providers'
	if ([string]::IsNullOrWhiteSpace($Provider)) {
		return @{}
	}
	if ($providers -is [hashtable] -and $providers.Contains($Provider)) {
		return $providers[$Provider]
	}
	return @{}
}

function Get-NitrogenPromptText {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][hashtable]$Config,
		[Parameter(Mandatory = $true)][hashtable]$ProfileConfig
	)
	$promptRef = Get-NitrogenMemberValue -InputObject $ProfileConfig -Name 'prompt'
	if ([string]::IsNullOrWhiteSpace($promptRef)) {
		return $null
	}
	$prompts = Get-NitrogenMemberValue -InputObject $Config -Name 'prompts'
	if ($prompts -isnot [hashtable] -or -not $prompts.Contains($promptRef)) {
		throw "Prompt reference '$promptRef' does not exist in config 'prompts'."
	}
	return $prompts[$promptRef]
}

function Get-NitrogenApiKey {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][ValidateSet('OpenAI', 'Anthropic', 'AzureOpenAI', 'Google', 'Perplexity', 'Ollama')][string]$Provider,
		[Parameter(Mandatory = $false)][hashtable]$ProviderConfig = @{}
	)
	$envVarName = switch ($Provider) {
		'OpenAI'     { 'OPENAI_API_KEY' }
		'Anthropic'  { 'ANTHROPIC_API_KEY' }
		'AzureOpenAI'{ 'AZURE_OPENAI_API_KEY' }
		'Google'     { 'GEMINI_API_KEY' }
		'Perplexity' { 'PERPLEXITY_API_KEY' }
		'Ollama'     { 'OLLAMA_API_KEY' }   # optional: Ollama itself needs no key
	}
	$envValue = [Environment]::GetEnvironmentVariable($envVarName)
	if (-not [string]::IsNullOrWhiteSpace($envValue)) {
		return $envValue
	}
	$secretRef = Get-NitrogenMemberValue -InputObject $ProviderConfig -Name 'apiKeyRef'
	if ([string]::IsNullOrWhiteSpace($secretRef)) {
		return $null
	}
	$getSecret = Get-Command -Name Get-Secret -ErrorAction SilentlyContinue
	if ($null -eq $getSecret) {
		throw "Provider '$Provider' is configured with apiKeyRef '$secretRef', but Get-Secret is unavailable. Install Microsoft.PowerShell.SecretManagement and register a vault."
	}
	try {
		$secret = Get-Secret -Name $secretRef -ErrorAction Stop
	}
	catch {
		throw "Failed to retrieve secret '$secretRef' for provider '$Provider': $($_.Exception.Message)"
	}
	if ($secret -is [securestring]) {
		$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
		try {
			$secret = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
		}
		finally {
			[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
		}
	}
	if ([string]::IsNullOrWhiteSpace([string]$secret)) {
		throw "Secret '$secretRef' for provider '$Provider' is empty."
	}
	return [string]$secret
}
