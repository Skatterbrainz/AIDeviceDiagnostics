function Get-GeminiModels {
	<#
	.SYNOPSIS
		Retrieves a list of available Google Gemini models.
	.DESCRIPTION
		Calls the Google Gemini API to list all available models.
	.PARAMETER ApiKey
		The Google Gemini API key. If not provided, the GEMINI_API_KEY environment variable will be used.
	.PARAMETER Refresh
		Forces a refresh of the cached models.
	.EXAMPLE
		Get-GeminiModels
		Retrieves the list of available Google Gemini models using the specified API key.
	.EXAMPLE
		Get-GeminiModels -Refresh
		Forces a refresh of the cached models.
	#>
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
					name                       = $model.name -replace "models/", ""
					displayName                = $model.displayName
					description                = $model.description
					inputTokenLimit            = $model.inputTokenLimit
					outputTokenLimit           = $model.outputTokenLimit
					supportedGenerationMethods = $model.supportedGenerationMethods
					temperature                = $model.temperature
					topP                       = $model.topP
					topK                       = $model.topK
					maxTemperature             = $model.maxTemperature
					thinking                   = $model.thinking
				})
		}
		$global:GEMINI_MODELS = $result
		return $result
	}
	catch {
		Write-Error "Failed to retrieve models: $($_.Exception.Message)"
	}
}