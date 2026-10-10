function Get-OpenAIModels {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][string]$Endpoint = "https://api.openai.com/v1/models",
        [Parameter(Mandatory=$false)][string]$ApiKey,
        [Parameter(Mandatory=$false)][int]$PageSize = 100
    )
    if (-not $ApiKey) { $ApiKey = $env:OPENAI_API_KEY }
    if (-not $ApiKey) {
        throw "OpenAI API key is not set. Provide it via -ApiKey or the OPENAI_API_KEY environment variable."
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

    $allModels
}