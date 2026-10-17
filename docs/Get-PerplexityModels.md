---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-PerplexityModels.md
schema: 2.0.0
---

# Get-PerplexityModels

## SYNOPSIS
Retrieves the list of available Perplexity models.

## SYNTAX

```powershell
Get-PerplexityModels [[-ApiKey] <String>] [-Refresh] [<CommonParameters>]
```

## DESCRIPTION

Calls the Perplexity models API and returns available models.

Results are cached in-memory for the current session. Use `-Refresh` to force an API refresh instead
of returning cached models.

If `-ApiKey` is not supplied, the command uses `$env:PERPLEXITY_API_KEY`.

## EXAMPLES

### Example 1

```powershell
Get-PerplexityModels
```

Returns available Perplexity models using `$env:PERPLEXITY_API_KEY`.

### Example 2

```powershell
Get-PerplexityModels -Refresh
```

Forces a refresh from the Perplexity API and updates the cached model list.

## PARAMETERS

### -ApiKey

Perplexity API key.

When omitted, `$env:PERPLEXITY_API_KEY` is used.

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

Forces a refresh of cached Perplexity models.

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
