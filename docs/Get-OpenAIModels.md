---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-OpenAIModels.md
schema: 2.0.0
---

# Get-OpenAIModels

## SYNOPSIS
Retrieves a list of available OpenAI models.

## SYNTAX

```powershell
Get-OpenAIModels [[-Endpoint] <String>] [[-ApiKey] <String>] [[-PageSize] <Int32>] [-Refresh]
 [<CommonParameters>]
```

## DESCRIPTION

Calls the OpenAI models API and retrieves all available models, handling pagination automatically.

Results are cached in-memory for the current session. Use `-Refresh` to force an API refresh instead
of returning cached models.

If `-ApiKey` is not supplied, the command uses `$env:OPENAI_API_KEY`.

## EXAMPLES

### Example 1

```powershell
Get-OpenAIModels
```

Returns available OpenAI models using the default endpoint and environment API key.

### Example 2

```powershell
Get-OpenAIModels -Refresh
```

Forces a fresh API retrieval and updates the cached model list.

### Example 3

```powershell
Get-OpenAIModels -PageSize 50
```

Retrieves models using pages of 50 items.

## PARAMETERS

### -Endpoint

OpenAI endpoint used to list models.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: https://api.openai.com/v1/models
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey

OpenAI API key.

When omitted, `$env:OPENAI_API_KEY` is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Number of models to request per API page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh

Forces a refresh of cached OpenAI models.

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
