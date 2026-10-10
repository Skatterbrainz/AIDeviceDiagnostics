function Get-GeminiModels {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$false)][string]$ApiKey,
		[parameter(Mandatory=$false)][switch]$Refresh
	)
	if ($global:GEMINI_MODELS -and -not $Refresh) {
		Write-Verbose 'Returning cached Gemini models'
		return $global:GEMINI_MODELS
	}
	Write-Verbose 'Retrieving Gemini models from API'
	if (-not $ApiKey) {
		$ApiKey = $env:GEMINI_API_KEY
	}
	if (-not $ApiKey) {
		throw "Google Gemini API key is not set. Please provide it via the -ApiKey parameter or the GEMINI_API_KEY environment variable."
	}
	$uri = "https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey"
	try {
		$response = Invoke-RestMethod -Uri $uri -Method Get
		$result = @()
		foreach ($model in $response.models) {
			$result += $([PSCustomObject]@{
				Name        = $model.name -replace "models/", ""
				DisplayName = $model.displayName
				Description = $model.description
			})
		}
		$global:GEMINI_MODELS = $result
		return $result
	}
	catch {
		Write-Error "Failed to retrieve models: $($_.Exception.Message)"
	}
}