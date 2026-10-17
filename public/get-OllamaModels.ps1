function Get-OllamaModels {
    <#
    .SYNOPSIS
        Retrieves the list of models available on an Ollama server.
    .DESCRIPTION
        Calls the Ollama /api/tags endpoint to list the models that have been pulled to the server.
        Results are cached in-memory for the current session. Use -Refresh to bypass the cache.
        This is also a quick way to test connectivity to an on-premises Ollama server.
    .PARAMETER Endpoint
        The Ollama server base URI. Defaults to "http://localhost:11434".
    .PARAMETER ApiKey
        Optional. Sent as a Bearer token if supplied, or if OLLAMA_API_KEY is set. Ollama itself does not
        require authentication, but a reverse proxy in front of it might.
    .PARAMETER TimeoutSec
        Request timeout in seconds. Defaults to 30.
    .PARAMETER Refresh
        If specified, forces a refresh of the cached list of Ollama models.
    .EXAMPLE
        Get-OllamaModels
        Lists the models on the local Ollama server.
    .EXAMPLE
        Get-OllamaModels -Endpoint "http://ollama01.contoso.local:11434" -Refresh
        Lists the models on a remote Ollama server, bypassing the cache.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][string]$Endpoint = "http://localhost:11434",
        [Parameter(Mandatory=$false)][string]$ApiKey,
        [Parameter(Mandatory=$false)][ValidateRange(1, 3600)][int]$TimeoutSec = 30,
        [Parameter(Mandatory=$false)][switch]$Refresh
    )
    if (-not $ApiKey) { $ApiKey = $env:OLLAMA_API_KEY }

    $baseUri = Resolve-OllamaBaseUri -Endpoint $Endpoint

    if ($global:OllamaModels -and $global:OllamaModelsEndpoint -eq $baseUri -and -not $Refresh) {
        Write-Verbose 'Returning cached Ollama models'
        return $global:OllamaModels
    }

    $headers = @{}
    if (-not [string]::IsNullOrWhiteSpace($ApiKey)) { $headers["Authorization"] = "Bearer $ApiKey" }

    try {
        $response = Invoke-RestMethod -Uri "$baseUri/api/tags" -Method Get -Headers $headers `
            -TimeoutSec $TimeoutSec -ErrorAction Stop
    }
    catch {
        $detail = if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $null }
        throw "Failed to list Ollama models from ${baseUri}: $($_.Exception.Message) $detail"
    }

    $models = @($response.models | ForEach-Object {
        [pscustomobject]@{
            Name              = $_.name
            ParameterSize     = $_.details.parameter_size
            QuantizationLevel = $_.details.quantization_level
            Family            = $_.details.family
            SizeGB            = [math]::Round($_.size / 1GB, 2)
            Modified          = $_.modified_at
        }
    })

    $global:OllamaModels = $models
    $global:OllamaModelsEndpoint = $baseUri
    $global:OllamaModels
}
