function Invoke-ClaudeRequest {
	<#
	.SYNOPSIS
		Invokes a request to the Claude API with the specified prompt and file.
	.DESCRIPTION
		Uploads the specified file to the Claude API and sends the prompt for processing.
	.PARAMETER Prompt
		The prompt to send to the Claude API.
	.PARAMETER File
		The path to the file to upload.
	.PARAMETER Endpoint
		The Claude API endpoint for generating content. Defaults to "https://api.anthropic.com/v1/messages".
	.PARAMETER FilesEndpoint
		The Claude API endpoint for uploading files. Defaults to "https://api.anthropic.com/v1/files".
	.PARAMETER ApiKey
		The Anthropic API key. If not provided, the ANTHROPIC_API_KEY environment variable will be used.
	.PARAMETER Model
		The Claude model to use. Defaults to "claude-sonnet-5-5".
	.PARAMETER ApiVersion
		The Anthropic API version to use. Defaults to "2023-06-01".
	.PARAMETER MaxTokens
		The maximum number of tokens to generate. Defaults to 1024.
	.EXAMPLE
		Invoke-ClaudeRequest -Prompt "Hello" -File "example.txt"
		Submits the prompt and file to the Claude API for processing.
	.NOTES
		This function requires a valid Anthropic API key and a file to upload.
		Ensure that the file size does not exceed 100 MB.
		The -Prompt and -File parameters are provided by Invoke-AIDeviceDiagnostics automatically.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$true)][string]$File,
		[Parameter(Mandatory=$false)][string]$Endpoint = "https://api.anthropic.com/v1/messages",
		[Parameter(Mandatory=$false)][string]$FilesEndpoint = "https://api.anthropic.com/v1/files",
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
	# upload file first
	if (-not (Test-Path $File)) {
		throw "File not found: $File"
	}
	Write-Verbose "Endpoint: $Endpoint"
	Write-Verbose "Files Endpoint: $FilesEndpoint"
	Write-Verbose "Uploading file $File"
	$headers = @{
		"x-api-key"         = $ApiKey
		"anthropic-version" = $ApiVersion
	}
	$uploadParams = @{
		Uri     = $FilesEndpoint
		Method  = "POST"
		Headers = $headers
		Form    = @{ file = Get-Item -Path $File }
	}
	$uploadResult = Invoke-RestMethod @uploadParams
	$fileId = $uploadResult.id  # e.g. "file_011CNha8iCJcU1wXNR6q4V8w"
	if ($fileId) {
		Write-Verbose "File uploaded successfully with ID $fileId"
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
					content = @(
						@{ type = "text"; text = $Prompt },
						@{ type = "document"; source = @{ type = "file"; file_id = $fileId }}
					)
				}
			)
		} | ConvertTo-Json -Depth 10
		if ($VerbosePreference -eq 'Continue') {
			Write-Verbose "Request Body: $Body"
		}
		$requestParams = @{
			Uri         = $Endpoint
			Method      = "Post"
			Headers     = $Headers
			Body        = ([System.Text.Encoding]::UTF8.GetBytes($Body))
			ContentType = "application/json"
			ErrorAction = 'Stop'
		}
		try {
			$Response = Invoke-RestMethod @requestParams
			$Response.content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text }
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
}
