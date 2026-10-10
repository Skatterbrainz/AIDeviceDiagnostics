function Invoke-PerplexityRequest {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$false)][string]$Endpoint = 'https://api.perplexity.ai/chat/completions',
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][ValidateSet('sonar','sonar-pro','sonar-reasoning','sonar-reasoning-pro','sonar-deep-research')][string]$Model = 'sonar-pro'
	)
	Write-Warning "This function has not yet been fully implemented."
	$proceed = Read-Host "Do you want to proceed? (Y/N)"
	if ($proceed -ne 'Y') {
		Write-Verbose "Aborting Perplexity request."
		return
	}
	Write-Verbose 'Invoking Perplexity request with model $Model'
	if (-not $ApiKey) {
		$ApiKey = $env:PERPLEXITY_API_KEY
	}
	if (-not $ApiKey) {
		throw 'Perplexity API key is not set. Please provide it via the -ApiKey parameter or the PERPLEXITY_API_KEY environment variable.'
	}
	$Headers = @{
		Authorization = "Bearer $ApiKey"
		'Content-Type' = 'application/json'
	}

	$Body = @{
		model = $Model
		messages = @(
			@{
				role    = "user"
				content = $Prompt
			}
		)
	} | ConvertTo-Json -Depth 10
	$requestParameters = @{
		Uri         = $Endpoint
		Method      = "Post"
		Headers     = $Headers
		Body        = $Body
		ErrorAction = 'Stop'
	}
	$Response = Invoke-RestMethod @requestParameters
	return $Response
}
