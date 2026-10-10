---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Invoke-AIDiagnostics.md
schema: 2.0.0
---

# Invoke-AIDiagnostics

## SYNOPSIS
Collects local system diagnostics and optionally submits them to an AI provider for analysis.

## SYNTAX

```powershell
Invoke-AIDiagnostics -Scope <String[]> [-OutputPath <String>] [-SubmitPrompt] [-Provider <String>]
 [-ApiKey <String>] [-MaxItems <Int32>] [-PassThru] [-JSonOutput] [<CommonParameters>]
```

## DESCRIPTION

`Invoke-AIDiagnostics` collects system diagnostic data from one or more scopes and writes the
results to `Diagnostics.json` in the selected output path.

You can optionally submit the collected diagnostics to a supported AI provider for summarized
analysis and recommendations.

On Linux, registry collection is skipped with a warning.

## EXAMPLES

### Example 1

```powershell
Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -SubmitPrompt -Provider OpenAI
```

Exports EventLog and Services diagnostics to the specified output path, then submits the data to
OpenAI for analysis.

### Example 2

```powershell
Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -SubmitPrompt -Provider Anthropic
```

Exports EventLog and Services diagnostics to the specified output path, then submits the data to
Anthropic for analysis.

### Example 3

```powershell
Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -PassThru
```

Exports EventLog and Services diagnostics to the specified output path and returns the collected
data as PowerShell objects.

### Example 4

```powershell
Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -PassThru -JSonOutput
```

Exports EventLog and Services diagnostics to the specified output path and returns the collected
data as JSON.

### Example 5

```powershell
Invoke-AIDiagnostics -Scope EventLog, Services -OutputPath "C:\Diagnostics" -MaxItems 50
```

Exports EventLog and Services diagnostics while limiting each scoped collection to 50 items.

## PARAMETERS

### -Scope

Specifies one or more diagnostic areas to collect.

Accepted values:
- `EventLog`
- `Services`
- `Processes`
- `Registry`
- `Disk`
- `Memory`
- `System`

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: EventLog, Services, Processes, Registry, Disk, Memory, System

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

Specifies the path where diagnostic output files are written.

Defaults:
- Windows: `$env:USERPROFILE\Documents\AIDiagnostics`
- Linux: `$env:HOME/Documents/AIDiagnostics`

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Platform dependent
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubmitPrompt

Submits the collected diagnostics file to the selected provider for AI analysis.

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

### -Provider

Specifies which AI provider to use when `-SubmitPrompt` is set.

Accepted values:
- `OpenAI`
- `Anthropic`
- `AzureOpenAI`
- `Google`
- `Perplexity`

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OpenAI, Anthropic, AzureOpenAI, Google, Perplexity

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey

Specifies an API key for the selected provider.

You can also use environment variables:
- `$env:OPENAI_API_KEY`
- `$env:CLAUDE_API_KEY`
- `$env:GEMINI_API_KEY`
- `$env:AZURE_OPENAI_API_KEY`
- `$env:PERPLEXITY_API_KEY`

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxItems

Limits the number of records collected per selected scope.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

Returns collected diagnostics to the pipeline.

Use with `-JSonOutput` to return JSON instead of objects.

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

### -JSonOutput

When used with `-PassThru`, returns diagnostics as JSON.

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

## INPUTS

### None

You can't pipe objects to this function.

## OUTPUTS

### System.Collections.Specialized.OrderedDictionary

Returned when `-PassThru` is specified and `-JSonOutput` is not used.

### System.String

Returned when `-PassThru -JSonOutput` is specified.

### None

No output is written unless `-PassThru` is specified.

## NOTES

Alias: `Invoke-AIDeviceDiagnostics`

Some options are platform-specific. Registry diagnostics are only available on Windows.

## RELATED LINKS

- [Invoke-AIDiagnostics on GitHub](https://github.com/Skatterbrainz/Nitrogen/docs/Invoke-AIDiagnostics.md)
