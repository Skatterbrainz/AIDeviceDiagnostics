function Invoke-ClaudeRequest {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://api.anthropic.com/v1/messages",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "claude-sonnet-5-5",
		[Parameter(Mandatory=$false)][string]$ApiVersion = "2023-06-01",
		[Parameter(Mandatory=$false)][int]$MaxTokens = 1024
	)
	Write-Verbose "Invoking Claude request with model $Model"
	if (-not $ApiKey) {
		$ApiKey = $env:ANTHROPIC_API_KEY
	}
	if (-not $ApiKey) {
		throw "Anthropic API key is not set. Please provide it via the -ApiKey parameter or the ANTHROPIC_API_KEY environment variable."
	}
	$Headers = @{
		"x-api-key"         = $ApiKey
		"anthropic-version" = $ApiVersion
		"Content-Type"      = "application/json"
	}
	$Body = @{
		model = $Model
		max_tokens = $MaxTokens
		messages = @(
			@{
				role = "user"
				content = "$Prompt"
			}
		)
	} | ConvertTo-Json -Depth 5
	if ($VerbosePreference -eq 'Continue') {
		Write-Verbose "Request Body: $Body"
	}
	$requestParams = @{
		Uri         = $Endpoint
		Method      = "Post"
		Headers     = $Headers
		Body        = ([System.Text.Encoding]::UTF8.GetBytes($Body))
		ErrorAction = 'Stop'
	}
	try {
		$Response = Invoke-RestMethod @requestParams
		$Response.content[0].text
	} catch {
		$detail = $null
		if ($_.ErrorDetails.Message) {
			$detail = $_.ErrorDetails.Message
		}
		elseif ($_.Exception.Response) {
			$reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
			$detail = $reader.ReadToEnd()
		}
		throw "Claude API request failed: $($_.Exception.Message)`n$detail"
	}
}
