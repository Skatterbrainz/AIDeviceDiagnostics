function Invoke-OpenAIRequest {
	<#
	.SYNOPSIS
		Invokes an OpenAI API request with a given prompt and file.
	.DESCRIPTION
		Uploads the specified file to OpenAI and sends a request with the given prompt.
		Returns the output text from the OpenAI response.
	.PARAMETER Prompt
		The prompt text to send to the OpenAI API.
	.PARAMETER File
		The path to the file to upload and include in the request.
	.PARAMETER Endpoint
		The OpenAI API endpoint for responses. Defaults to "https://api.openai.com/v1/responses".
	.PARAMETER FilesEndpoint
		The OpenAI API endpoint for file uploads. Defaults to "https://api.openai.com/v1/files".
	.PARAMETER ApiKey
		The OpenAI API key. If not provided, the OPENAI_API_KEY environment variable will be used.
	.PARAMETER Model
		The model to use for the request. Defaults to "gpt-5".
	.EXAMPLE
		Invoke-OpenAIRequest -Prompt "Analyze this file" -File "data.txt"
		# This example demonstrates how to call the function with a prompt and a file.
	.NOTES
		The -Prompt and -File parameters are provided from Invoke-AIDeviceDiagnostics automatically.
		Ensure that the OPENAI_API_KEY environment variable is set if the -ApiKey parameter is not used.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$true)][string]$File,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://api.openai.com/v1/responses",
		[Parameter(Mandatory=$false)][string]$FilesEndpoint = "https://api.openai.com/v1/files",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "gpt-5"
	)
	Write-Verbose "Invoking OpenAI request with model $Model"

	if (-not $ApiKey) { $ApiKey = $env:OPENAI_API_KEY }
	if (-not $ApiKey) {
		throw "OpenAI API key is not set. Provide it via -ApiKey or the OPENAI_API_KEY environment variable."
	}
	if (-not (Test-Path $File)) { throw "File not found: $File" }

	Write-Verbose "Uploading file $File"
	$FileResponse = Invoke-RestMethod -Uri $FilesEndpoint -Method Post `
		-Headers @{ "Authorization" = "Bearer $ApiKey" } `
		-Form @{ purpose = "user_data"; file = Get-Item $File }
	if (-not $FileResponse.id) { throw "Failed to upload file to OpenAI." }
	Write-Verbose "Uploaded file with ID $($FileResponse.id)"

	$Body = @{
		model = $Model
		input = @(
			@{
				role    = "user"
				content = @(
					@{ type = "input_file"; file_id = $FileResponse.id },
					@{ type = "input_text"; text = $Prompt }
				)
			}
		)
	} | ConvertTo-Json -Depth 10

	$requestParams = @{
		Uri                = $Endpoint
		Method             = "Post"
		Headers            = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }
		Body               = ([System.Text.Encoding]::UTF8.GetBytes($Body))
		ErrorAction        = 'Stop'
		SkipHttpErrorCheck = $true
		StatusCodeVariable = "statusCode"
	}
	$Response = Invoke-RestMethod @requestParams

	if ($statusCode -ne 200) {
		throw "OpenAI API request failed ($statusCode): $($Response | ConvertTo-Json -Depth 5)"
	}

	$Response.output | Where-Object { $_.type -eq "message" } |
		ForEach-Object { $_.content | Where-Object { $_.type -eq "output_text" } | ForEach-Object { $_.text } }
}