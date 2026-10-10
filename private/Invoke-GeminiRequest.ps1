function Invoke-GeminiRequest {
	<#
	.SYNOPSIS
		Invokes a request to the Google Gemini API with the specified prompt and file.
	.DESCRIPTION
		Uploads the specified file to the Google Gemini API and sends the prompt for processing.
	.PARAMETER Prompt
		The prompt to send to the Google Gemini API.
	.PARAMETER File
		The path to the file to upload.
	.PARAMETER Endpoint
		The Google Gemini API endpoint for generating content. Defaults to "https://generativelanguage.googleapis.com/v1beta".
	.PARAMETER FilesEndpoint
		The Google Gemini API endpoint for uploading files. Defaults to "https://generativelanguage.googleapis.com/v1beta/files".
	.PARAMETER ApiKey
		The Google Gemini API key. If not provided, the GEMINI_API_KEY environment variable will be used.
	.PARAMETER Model
		The Google Gemini model to use. Defaults to "gemini-3.5-flash".
	.EXAMPLE
		Invoke-GeminiRequest -Prompt "Hello" -File "example.txt"
		Submits the prompt and file to the Google Gemini API for processing.
	.NOTES
		This function requires a valid Google Gemini API key and a file to upload.
		Ensure that the file size does not exceed 100 MB.
		The -Prompt and -File parameters are provided by Invoke-AIDeviceDiagnostics automatically.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$true)][string]$File,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://generativelanguage.googleapis.com/v1beta",
		[Parameter(Mandatory=$false)][string]$FilesEndpoint = "https://generativelanguage.googleapis.com/v1beta/files",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "gemini-3.5-flash"
	)
	Write-Verbose "Invoking Google Gemini request with model $Model"
	if (-not $ApiKey) {
		$ApiKey = $env:GEMINI_API_KEY
	}
	if (-not $ApiKey) {
		throw "Google Gemini API key is not set. Please provide it via the -ApiKey parameter or the GEMINI_API_KEY environment variable."
	}
	# upload file first
	if (-not (Test-Path $File)) {
		throw "File not found: $File"
	}
	Write-Verbose "Uploading file $File"
	$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($File))
	# verify file content is < 100 MB
	if ($base64.Length -gt 100MB) {
		throw "File size exceeds 100 MB limit."
	}
	$body = @{
		contents = @(
			@{
				role  = "user"
				parts = @(
					@{ text = $Prompt },
					@{ inlineData = @{ mimeType = "text/plain"; data = $base64 } }
				)
			}
		)
	} | ConvertTo-Json -Depth 10
	#Write-Verbose "Request Parameters: $($Body)"
	$requestParams = @{
		Uri                = "$Endpoint/models/$($Model):generateContent"
		Method             = "Post"
		Headers            = @{ "x-goog-api-key" = $ApiKey }
		Body               = ([System.Text.Encoding]::UTF8.GetBytes($body))
		ContentType        = "application/json"
		SkipHttpErrorCheck = $true
		StatusCodeVariable = "statusCode"
		ErrorAction        = 'Stop'
	}
	try {
		Write-Verbose "Sending request to $($requestParams.Uri)"
		$Response = Invoke-RestMethod @requestParams
		if ($statusCode -ne 200) {
			throw "Google Gemini API request failed ($statusCode): $($Response | ConvertTo-Json -Depth 5)"
		}
		$Response.candidates[0].content.parts | Where-Object { $_.text } | ForEach-Object { $_.text }
	} catch {
		$detail = $_.ErrorDetails.Message -or $_.Exception.Message
		throw "Google Gemini API request failed: $detail"
	}
}
