---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-AnthropicModels.md
schema: 2.0.0
---

# Get-AnthropicModels

## SYNOPSIS
Retrieves the list of available Anthropic models.

## SYNTAX

```powershell
Get-AnthropicModels [[-ApiKey] <String>] [[-ApiVersion] <String>] [-Refresh] [<CommonParameters>]
```

## DESCRIPTION

Calls the Anthropic models API and returns available models.

Results are cached in-memory for the current session. Use `-Refresh` to force an API refresh instead
of returning cached models.

If `-ApiKey` is not supplied, the command uses `$env:ANTHROPIC_API_KEY`.

## EXAMPLES

### Example 1

```powershell
Get-AnthropicModels
```

Returns available Anthropic models using `$env:ANTHROPIC_API_KEY`.

### Example 2

```powershell
Get-AnthropicModels -ApiVersion 2023-06-01 -Refresh
```

Forces a fresh model retrieval using the specified Anthropic API version header.

## PARAMETERS

### -ApiKey

Anthropic API key.

When omitted, `$env:ANTHROPIC_API_KEY` is used.

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

### -ApiVersion

Value for the `Anthropic-Version` request header.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 2023-06-01
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh

Forces a refresh of cached Anthropic models.

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
