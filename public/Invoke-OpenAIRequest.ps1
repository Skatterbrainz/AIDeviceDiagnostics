function Invoke-OpenAIRequest {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://api.openai.com/v1/responses",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "gpt-5"
	)
	Write-Verbose "Invoking OpenAI request with model $Model"
	if (-not $ApiKey) {
		$ApiKey = $env:OPENAI_API_KEY
	}
	if (-not $ApiKey) {
		throw "OpenAI API key is not set. Please provide it via the -ApiKey parameter or the OPENAI_API_KEY environment variable."
	}
	$Headers = @{
		"Authorization" = "Bearer $ApiKey"
		"Content-Type"  = "application/json"
	}
	$Body = @{
		model = $Model
		input = $Prompt
	} | ConvertTo-Json -Depth 10
	$requestParams = @{
		Uri         = $Endpoint
		Method      = "Post"
		Headers     = $Headers
		Body        = $Body
		ErrorAction = 'Stop'
	}
	$Response = Invoke-RestMethod @requestParams
	$Response.output.content[0].text
}
