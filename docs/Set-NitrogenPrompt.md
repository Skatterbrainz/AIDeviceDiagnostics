---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Set-NitrogenPrompt.md
schema: 2.0.0
---

# Set-NitrogenPrompt

## SYNOPSIS
Creates or updates a prompt entry in Nitrogen config.

## SYNTAX

```powershell
Set-NitrogenPrompt -Key <String> -Prompt <String> [[-Scope] <String>] [[-ConfigPath] <String>]
 [[-ProfileName] <String>] [-CreateProfile] [<CommonParameters>]
```

## DESCRIPTION

Writes prompt text to `prompts.<Key>` and optionally assigns that key to a profile by setting
`profiles.<ProfileName>.prompt`.

## EXAMPLES

### Example 1

```powershell
Set-NitrogenPrompt -Key diagnostics.default -Prompt "Analyze diagnostics and provide actions."
```

Updates prompt text in global config.

### Example 2

```powershell
Set-NitrogenPrompt -Scope Local -Key diagnostics.short -Prompt "Keep output short." -ProfileName default
```

Updates local prompt and assigns it to profile `default`.

### Example 3

```powershell
Set-NitrogenPrompt -ConfigPath ./config/nitrogen.json -Key diagnostics.work -Prompt "Focus on production-impacting findings." -ProfileName work -CreateProfile
```

Updates explicit config path and creates the profile when missing.

## PARAMETERS

### -Key

Prompt key name under `prompts`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompt

Prompt text value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope

Target scope when `-ConfigPath` is not provided.

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

Explicit config file path to update.

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

Optional profile to assign to this prompt key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateProfile

Creates `-ProfileName` if missing.

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
