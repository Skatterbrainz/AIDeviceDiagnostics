function Get-AnthropicModels {
    <#
    .SYNOPSIS
        Retrieves the list of available Anthropic models.
    .DESCRIPTION
        Sends a request to the Anthropic API to get the list of models that can be used for generating completions.
    .PARAMETER ApiKey
        The Anthropic API key. If not provided, the ANTHROPIC_API_KEY environment variable will be used.
    .PARAMETER Refresh
        If specified, forces a refresh of the cached list of Anthropic models.
    .EXAMPLE
        Get-AnthropicModels
        Retrieves the list of available Anthropic models using the specified API key.
    .EXAMPLE
        Get-AnthropicModels -Refresh
        Forces a refresh of the cached list of Anthropic models.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][string]$ApiKey,
        [Parameter(Mandatory=$false)][string]$ApiVersion = "2023-06-01",
        [Parameter(Mandatory=$false)][switch]$Refresh
    )
    if ($global:ANTHROPIC_MODELS -and -not $Refresh) {
        Write-Verbose 'Returning cached Anthropic models'
        return $global:ANTHROPIC_MODELS
    }
    if (-not $ApiKey) {
        $ApiKey = $env:ANTHROPIC_API_KEY
    }
    if (-not $ApiKey) {
        throw 'Anthropic API key is not set. Please provide it via the -ApiKey parameter or the ANTHROPIC_API_KEY environment variable.'
    }
    $Headers = @{
        "x-api-key" = $ApiKey
        'Anthropic-Version' = $ApiVersion
    }
    $requestParameters = @{
        Uri         = "https://api.anthropic.com/v1/models?limit=100"
        Method      = "Get"
        Headers     = $Headers
        ErrorAction = 'Stop'
    }
    $response = (Invoke-RestMethod @requestParameters).data |
        Select-Object id, line, display_name,max_input_tokens,max_tokens,lifecycle

    $global:ANTHROPIC_MODELS = $Response
    return $global:ANTHROPIC_MODELS
}