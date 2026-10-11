---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Initialize-NitrogenConfig.md
schema: 2.0.0
---

# Initialize-NitrogenConfig

## SYNOPSIS
Creates a starter Nitrogen config file and optionally stores provider API secrets.

## SYNTAX

```powershell
Initialize-NitrogenConfig [[-Scope] <String>] [[-ConfigPath] <String>] [[-ProfileName] <String>]
 [[-Provider] <String>] [[-PromptKey] <String>] [[-PromptText] <String>] [[-MaxItems] <Int32>] [-Force]
 [-ConfigureSecretVault] [-SetSecrets] [<CommonParameters>]
```

## DESCRIPTION

`Initialize-NitrogenConfig` writes a starter JSON configuration for Nitrogen.

By default it writes global config to:

- `~/.nitrogen/config.json`

You can target local project config with `-Scope Local` or provide a custom path with `-ConfigPath`.

When used with `-ConfigureSecretVault`, the command attempts to register `SecretStore` as the default
vault if SecretManagement is available.

When used with `-SetSecrets`, the command prompts for provider API keys and stores them securely
using `Set-Secret` with each provider's configured `apiKeyRef`.

## EXAMPLES

### Example 1

```powershell
Initialize-NitrogenConfig
```

Creates a global starter config with default profile and provider settings.

### Example 2

```powershell
Initialize-NitrogenConfig -Scope Local -ProfileName work -Provider Anthropic
```

Creates a local project config with profile `work` and `Anthropic` as the default provider.

### Example 3

```powershell
Initialize-NitrogenConfig -ConfigureSecretVault -SetSecrets
```

Creates config, attempts to configure SecretStore as default vault, and prompts for API keys.

## PARAMETERS

### -Scope

Target config scope when `-ConfigPath` is not provided.

Accepted values: `Global`, `Local`

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Global, Local

Required: False
Position: 0
Default value: Global
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPath

Explicit path for the config file. Overrides `-Scope`.

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

### -ProfileName

Profile name to create in the config.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Provider

Default provider to assign in generated defaults and profile settings.

Accepted values: `OpenAI`, `Anthropic`, `AzureOpenAI`, `Google`, `Perplexity`

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OpenAI, Anthropic, AzureOpenAI, Google, Perplexity

Required: False
Position: 3
Default value: OpenAI
Accept pipeline input: False
Accept wildcard characters: False
```

### -PromptKey

Prompt key name to store under `prompts`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: diagnostics.default
Accept pipeline input: False
Accept wildcard characters: False
```

### -PromptText

Prompt text associated with `-PromptKey`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Analyze diagnostics and return concise, actionable findings.
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxItems

Default max item limit written to config defaults and the generated profile.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Overwrites the target config file if it already exists.

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

### -ConfigureSecretVault

Attempts to register SecretStore as the default secret vault when available.

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

### -SetSecrets

Prompts for provider API keys and stores them with `Set-Secret`.

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

### System.Management.Automation.PSCustomObject

Returns summary fields: `ConfigPath`, `Profile`, `DefaultProvider`, `SecretVault`, and `SecretsStored`.
