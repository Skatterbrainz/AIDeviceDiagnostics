---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-GeminiModels.md
schema: 2.0.0
---

# Get-GeminiModels

## SYNOPSIS
Retrieves a list of available Google Gemini models.

## SYNTAX

```powershell
Get-GeminiModels [[-ApiKey] <String>] [-Refresh] [<CommonParameters>]
```

## DESCRIPTION

Calls the Google Gemini API and returns available models.

Results are cached in-memory for the current session. Use `-Refresh` to force an API refresh instead
of returning cached models.

If `-ApiKey` is not supplied, the command uses `$env:GEMINI_API_KEY`.

## EXAMPLES

### Example 1

```powershell
Get-GeminiModels
```

Returns available Gemini models using `$env:GEMINI_API_KEY`.

### Example 2

```powershell
Get-GeminiModels -Refresh
```

Forces a refresh from the Gemini API and updates the cached model list.

## PARAMETERS

### -ApiKey

Google Gemini API key.

When omitted, `$env:GEMINI_API_KEY` is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh

Forces a refresh of cached Gemini models.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## OUTPUTS

### System.Management.Automation.PSCustomObject[]

Each model entry includes:
- `name`
- `displayName`
- `description`
- `inputTokenLimit`
- `outputTokenLimit`
- `supportedGenerationMethods`
- `temperature`
- `topP`
- `topK`
- `maxTemperature`
- `thinking`
