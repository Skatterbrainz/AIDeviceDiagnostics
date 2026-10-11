---
external help file: Nitrogen-help.xml
Module Name: Nitrogen
online version: https://github.com/Skatterbrainz/Nitrogen/docs/Get-NitrogenConfig.md
schema: 2.0.0
---

# Get-NitrogenConfig

## SYNOPSIS
Reads Nitrogen configuration.

## SYNTAX

```powershell
Get-NitrogenConfig [[-Scope] <String>] [[-ConfigPath] <String>] [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION

Reads Nitrogen configuration from:

- global config (`~/.nitrogen/config.json`)
- local config (`./.nitrogen/config.json`)
- effective merged config (global + local)
- explicit path (`-ConfigPath`)

## EXAMPLES

### Example 1

```powershell
Get-NitrogenConfig
```

Returns effective merged configuration.

### Example 2

```powershell
Get-NitrogenConfig -Scope Local
```

Returns local project config only.

### Example 3

```powershell
Get-NitrogenConfig -ConfigPath ./config/nitrogen.json -AsHashtable
```

Returns explicit config path as hashtable.

## PARAMETERS

### -Scope

Configuration scope.

Accepted values: `Global`, `Local`, `Effective`

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Global, Local, Effective

Required: False
Position: 0
Default value: Effective
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPath

Explicit config file path to read.

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

### -AsHashtable

Returns hashtable output instead of PSCustomObject.

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
