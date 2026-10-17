---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-OllamaModels.md
schema: 2.0.0
---

# Get-OllamaModels

## SYNOPSIS
Retrieves the list of models available on an Ollama server.

## SYNTAX

```powershell
Get-OllamaModels [[-Endpoint] <String>] [[-ApiKey] <String>] [[-TimeoutSec] <Int32>] [-Refresh] [<CommonParameters>]
```

## DESCRIPTION

Calls the Ollama `/api/tags` endpoint and returns the models that have been pulled to the server.

Results are cached in-memory for the current session, per endpoint. Use `-Refresh` to force a new request.
This is also a quick way to test connectivity to an on-premises Ollama server.

Ollama does not require authentication. If `-ApiKey` is supplied, or `$env:OLLAMA_API_KEY` is set, it is sent
as a Bearer token (useful when a reverse proxy sits in front of Ollama).

## EXAMPLES

### Example 1
```powershell
Get-OllamaModels
```

Lists the models on the local Ollama server (`http://localhost:11434`).

### Example 2
```powershell
Get-OllamaModels -Endpoint "http://ollama01.contoso.local:11434" -Refresh
```

Lists the models on a remote Ollama server, bypassing the cache.

## PARAMETERS

### -Endpoint
The Ollama server base URI. Defaults to `http://localhost:11434`.

```yaml
Type: String
Required: False
Position: 1
Default value: http://localhost:11434
```

### -ApiKey
Optional Bearer token for an authenticating proxy. Defaults to `$env:OLLAMA_API_KEY` when set.

```yaml
Type: String
Required: False
Position: 2
```

### -TimeoutSec
Request timeout in seconds. Valid range is 1 to 3600.

```yaml
Type: Int32
Required: False
Position: 3
Default value: 30
```

### -Refresh
Bypasses the in-memory cache and requests the model list again.

```yaml
Type: SwitchParameter
Required: False
```

## OUTPUTS

`PSCustomObject` with `Name`, `ParameterSize`, `QuantizationLevel`, `Family`, `SizeGB` and `Modified`.
