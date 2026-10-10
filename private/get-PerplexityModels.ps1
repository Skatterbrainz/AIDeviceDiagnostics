function Get-PerplexityModels {
    <#
    .SYNOPSIS
        Retrieves the list of available Perplexity models.
    .DESCRIPTION
        Sends a request to the Perplexity API to get the list of models that can be used for generating completions.
    .PARAMETER ApiKey
        The Perplexity API key. If not provided, the PERPLEXITY_API_KEY environment variable will be used.
    .EXAMPLE
        Get-PerplexityModels
        Retrieves the list of available Perplexity models using the specified API key.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][string]$ApiKey
    )
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
    $Endpoint = 'https://api.perplexity.ai/models'
    $requestParameters = @{
        Uri         = $Endpoint
        Method      = "Get"
        Headers     = $Headers
        ErrorAction = 'Stop'
    }
    $Response = Invoke-RestMethod @requestParameters
    return $Response
}