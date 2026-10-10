function Invoke-GeminiRequest {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://generativelanguage.googleapis.com/v1beta",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "gemini-3.8-flash"
	)
	Write-Verbose "Invoking Google Gemini request with model $Model"
	if (-not $ApiKey) {
		$ApiKey = $env:GEMINI_API_KEY
	}
	if (-not $ApiKey) {
		throw "Google Gemini API key is not set. Please provide it via the -ApiKey parameter or the GEMINI_API_KEY environment variable."
	}
	$Headers = @{
		"Content-Type" = "application/json"
	}
	$Body = @{
		contents = @(
			@{
				parts = @(
					@{
						text = "$Prompt"
					}
				)
			}
		)
	} | ConvertTo-Json -Depth 5
	if ($VerbosePreference -eq "Continue") {
		Write-Verbose "Request Parameters: $($Body)"
	}
	$requestParams = @{
		Uri         = "$EndPoint/models/${Model}:generateContent?key=$ApiKey"
		Method      = "Post"
		ContentType = "application/json"
		Headers     = $Headers
		Body        = $Body
		ErrorAction = 'Stop'
	}
	try {
		$Response = Invoke-RestMethod @requestParams
		$Response.candidates.content.parts.text
	} catch {
		$detail = $null
		if ($_.ErrorDetails.Message) {
			$detail = $_.ErrorDetails.Message
		}
		elseif ($_.Exception.Response) {
			$reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
			$detail = $reader.ReadToEnd()
		}
		throw "Google Gemini API request failed: $($_.Exception.Message)`n$detail"
	}
}
