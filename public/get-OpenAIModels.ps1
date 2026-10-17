function Get-OpenAIModels {
    <#
    .SYNOPSIS
        Retrieves a list of available OpenAI models.
    .DESCRIPTION
        Calls the OpenAI API to list all available models, handling pagination automatically.
    .PARAMETER Endpoint
        The OpenAI API endpoint for listing models. Defaults to "https://api.openai.com/v1/models".
    .PARAMETER ApiKey
        The OpenAI API key. If not provided, the OPENAI_API_KEY environment variable will be used.
    .PARAMETER PageSize
        The number of models to retrieve per API request. Defaults to 100.
    .PARAMETER Refresh
        If specified, forces a refresh of the cached list of models.
    .EXAMPLE
        Get-OpenAIModels
        Retrieves the list of available OpenAI models using the specified API key, fetching 100 models per request.
    .EXAMPLE
        Get-OpenAIModels -Refresh
        Forces a refresh of the cached list of OpenAI models.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][string]$Endpoint = "https://api.openai.com/v1/models",
        [Parameter(Mandatory=$false)][string]$ApiKey,
        [Parameter(Mandatory=$false)][int]$PageSize = 100,
        [Parameter(Mandatory=$false)][switch]$Refresh
    )
    if (-not $ApiKey) { $ApiKey = $env:OPENAI_API_KEY }
    if (-not $ApiKey) {
        throw "OpenAI API key is not set. Provide it via -ApiKey or the OPENAI_API_KEY environment variable."
    }

    if ($global:OpenAIModels -and -not $Refresh) {
		Write-Verbose 'Returning cached OpenAI models'
		return $global:OpenAIModels
	}

    $allModels = [System.Collections.Generic.List[object]]::new()
    $after = $null

    do {
        $uri = $Endpoint
        if ($after) {
            $uri += "?after=$after&limit=$PageSize"
        } else {
            $uri += "?limit=$PageSize"
        }

        $Response = Invoke-RestMethod -Uri $uri -Method Get `
            -Headers @{ "Authorization" = "Bearer $ApiKey" } `
            -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        if ($statusCode -ne 200) {
            throw "Failed to list models ($statusCode): $($Response | ConvertTo-Json -Depth 5)"
        }

        $allModels.AddRange($Response.data)
        $after = $Response.data[-1].id
    } while ($Response.data.Count -eq $PageSize)

    if ($Refresh -or -not $global:OpenAIModels) {
        $global:OpenAIModels = $allModels
    }
    $global:OpenAIModels
}