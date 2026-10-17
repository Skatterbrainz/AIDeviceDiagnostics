function Resolve-OllamaBaseUri {
	<#
	.SYNOPSIS
		Normalizes an Ollama endpoint to a base URI with no trailing slash or API path.
	.DESCRIPTION
		Accepts "http://host:11434", "http://host:11434/" or a full path such as
		"http://host:11434/api/chat" and returns "http://host:11434" so callers can append
		the API path they need.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Endpoint
	)
	$base = $Endpoint.Trim().TrimEnd('/')
	$base = $base -replace '/api(/[^/]+)*$', ''
	return $base
}

function Invoke-OllamaRequest {
	<#
	.SYNOPSIS
		Invokes a chat request against an on-premises Ollama server with the given prompt and file.
	.DESCRIPTION
		Reads the specified diagnostics file and sends its contents inline, together with the prompt,
		to the Ollama /api/chat endpoint. Ollama has no file upload API, so the JSON content is
		embedded in the user message. Returns the response text from the model.

		Works in Windows PowerShell 5.1 and PowerShell 7+.
	.PARAMETER Prompt
		The prompt text to send to the model.
	.PARAMETER File
		The path to the diagnostics file whose content is included in the request.
	.PARAMETER Endpoint
		The Ollama server base URI. Defaults to "http://localhost:11434".
		A full "/api/chat" URI is also accepted.
	.PARAMETER ApiKey
		Optional. Ollama does not require authentication. If supplied (or if OLLAMA_API_KEY is set),
		it is sent as a Bearer token, which is useful when Ollama sits behind a reverse proxy.
	.PARAMETER Model
		The model to use. Defaults to "llama3.1:8b". The model must already be pulled on the server.
	.PARAMETER NumCtx
		Context window size in tokens. Defaults to 16384. Ollama's own default is small and will
		silently truncate large diagnostics, so raise this for multi-scope collections.
	.PARAMETER MaxTokens
		Maximum number of tokens to generate (num_predict). Defaults to the server/model setting.
	.PARAMETER TimeoutSec
		Request timeout in seconds. Defaults to 300. Local inference can be slow on modest hardware.
	.PARAMETER KeepAlive
		How long the model stays loaded after the request (for example "10m"). Defaults to the server setting.
	.PARAMETER Format
		Optional. Set to "json" to constrain the model output to valid JSON.
	.EXAMPLE
		Invoke-OllamaRequest -Prompt "Analyze this data" -File "Diagnostics.json" -Endpoint "http://ollama01.contoso.local:11434" -Model "qwen2.5:14b"
	.NOTES
		The -Prompt and -File parameters are provided from Invoke-AIDiagnostics automatically.
		A warning is written when the file is estimated to exceed about 80 percent of NumCtx.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)][string]$Prompt,
		[Parameter(Mandatory=$true)][string]$File,
		[Parameter(Mandatory=$false)][string]$Endpoint = "http://localhost:11434",
		[Parameter(Mandatory=$false)][string]$ApiKey,
		[Parameter(Mandatory=$false)][string]$Model = "llama3.1:8b",
		[Parameter(Mandatory=$false)][ValidateRange(512, 1048576)][int]$NumCtx = 16384,
		[Parameter(Mandatory=$false)][int]$MaxTokens,
		[Parameter(Mandatory=$false)][ValidateRange(1, 86400)][int]$TimeoutSec = 300,
		[Parameter(Mandatory=$false)][string]$KeepAlive,
		[Parameter(Mandatory=$false)][ValidateSet('json')][string]$Format
	)
	Write-Verbose "Invoking Ollama request with model $Model"
	if (-not $ApiKey) { $ApiKey = $env:OLLAMA_API_KEY }
	if (-not (Test-Path $File)) { throw "File not found: $File" }

	$baseUri = Resolve-OllamaBaseUri -Endpoint $Endpoint
	$chatUri = "$baseUri/api/chat"
	Write-Verbose "Chat endpoint: $chatUri"

	$data = Get-Content -Path $File -Raw -ErrorAction Stop
	$estimatedTokens = [math]::Ceiling($data.Length / 4)
	if ($estimatedTokens -gt ($NumCtx * 0.8)) {
		$sizeWarning = "Diagnostics data is roughly $estimatedTokens tokens, which is close to or above the context window ($NumCtx). " +
			"The model may truncate its input. Increase numCtx, reduce -MaxItems, or collect fewer scopes."
		Write-Warning $sizeWarning
	}

	$content = "$Prompt`n`nDiagnostics data (JSON):`n``````json`n$data`n``````"

	$options = @{ num_ctx = $NumCtx }
	if ($PSBoundParameters.ContainsKey('MaxTokens') -and $MaxTokens -gt 0) { $options.num_predict = $MaxTokens }

	$payload = @{
		model    = $Model
		stream   = $false
		messages = @(
			@{ role = "user"; content = $content }
		)
		options  = $options
	}
	if (-not [string]::IsNullOrWhiteSpace($KeepAlive)) { $payload.keep_alive = $KeepAlive }
	if (-not [string]::IsNullOrWhiteSpace($Format))    { $payload.format = $Format }

	$Body = $payload | ConvertTo-Json -Depth 10

	$Headers = @{}
	if (-not [string]::IsNullOrWhiteSpace($ApiKey)) { $Headers["Authorization"] = "Bearer $ApiKey" }

	$requestParams = @{
		Uri         = $chatUri
		Method      = "Post"
		Headers     = $Headers
		Body        = ([System.Text.Encoding]::UTF8.GetBytes($Body))
		ContentType = "application/json; charset=utf-8"
		TimeoutSec  = $TimeoutSec
		ErrorAction = 'Stop'
	}
	try {
		$Response = Invoke-RestMethod @requestParams
	}
	catch {
		$detail = $null
		if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
			$detail = $_.ErrorDetails.Message
		}
		elseif ($_.Exception.Response) {
			try {
				$reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
				$detail = $reader.ReadToEnd()
			}
			catch { }
		}
		throw "Ollama API request failed: $($_.Exception.Message)`n$detail"
	}

	if ($Response.done_reason -eq 'length') {
		Write-Warning "The model stopped because it reached the output token limit. Increase maxTokens if the response looks cut off."
	}
	$Response.message.content
}
