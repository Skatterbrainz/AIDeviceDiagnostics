# Nitrogen

PowerShell module for collecting local diagnostics and optionally sending them to AI providers for analysis.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-orange)
![License](https://img.shields.io/badge/license-MIT-green)

Nitrogen collects targeted system telemetry (event logs, services, processes, disk, memory, and system details), saves the results to JSON, and can submit a prompt to supported AI APIs for troubleshooting guidance.

## 🎯 Overview

This module is designed for quick, repeatable diagnostics on local machines with an AI-assisted workflow when needed:

- collect only the scopes you care about
- capture problematic-only entries where supported
- persist output to disk for audit/sharing
- optionally submit a summary prompt to OpenAI, Anthropic, Azure OpenAI, Google Gemini, or Perplexity

## ✨ Features

- 🩺 **Multi-scope diagnostics** - Collect `EventLog`, `Services`, `Processes`, `Registry`, `Disk`, `Memory`, and `System`
- 💾 **Structured output** - Saves `Diagnostics.json` to your selected output folder
- 🧠 **AI-assisted analysis** - Submit collected data to supported AI providers
- 🧰 **Cross-platform defaults** - Sensible output path defaults on Windows and Linux
- ⚠️ **Problem-focused mode** - Use `-ProblemsOnly` to target likely issues where applicable
- 📤 **Flexible output modes** - Return object output (`-PassThru`) or JSON (`-JSonOutput`)

## Requirements

- PowerShell 5.1 or higher
- Windows PowerShell or PowerShell (Core) on Windows/Linux
- Network connectivity for AI provider calls (`-SubmitPrompt`)
- API keys via one of:
  - Environment variables, or
  - SecretManagement (`Get-Secret`) with `apiKeyRef` in config
- Optional on Linux: [`linuxtools`](https://github.com/Skatterbrainz/LinuxTools) module for richer Linux-specific diagnostics
- Optional for secure secret references: `Microsoft.PowerShell.SecretManagement` and a registered vault (such as SecretStore)
- Time. We all need more time.
- Coffee. Yeah, probably need some coffee too (or tea, or energy drinks, if that's your thing)

## Installation

### From PowerShell Gallery

PowerShell Core
   ```powershell
   Install-PSResource Nitrogen
   ```
Windows PowerShell
   ```powershell
   Install-Module Nitrogen
   ```
### From GitHub

2. **Clone the repository**
   ```bash
   git clone https://github.com/Skatterbrainz/Nitrogen.git
   cd Nitrogen
   ```

3. **Import the module**
   ```powershell
   Import-Module ./Nitrogen.psd1
   ```

## Usage

Import the module and run targeted diagnostics:

```powershell
# Import module
Import-Module Nitrogen

# View command help
Get-Help Invoke-AIDiagnostics -Full

# Create a starter config
Initialize-NitrogenConfig

# View effective merged config
Get-NitrogenConfig

# Update prompt text in global config
Set-NitrogenPrompt -Key diagnostics.default -Prompt "Analyze diagnostics and provide concise actions."

# Collect event log and services diagnostics to default path
Invoke-AIDiagnostics -Scope EventLog,Services

# Return diagnostics as objects
Invoke-AIDiagnostics -Scope Processes,Disk,Memory,System -PassThru

# Return diagnostics as JSON text
Invoke-AIDiagnostics -Scope EventLog,Services -PassThru -JSonOutput

# Submit diagnostics to OpenAI
Invoke-AIDiagnostics -Scope EventLog,Services,System -SubmitPrompt -Provider OpenAI

# Use profile and config file
Invoke-AIDiagnostics -Scope EventLog,Services -SubmitPrompt -Profile default

# Include AI response in PassThru output under "Diagnosis"
Invoke-AIDiagnostics -Scope EventLog,Services -SubmitPrompt -Provider OpenAI -PassThru
```

### Default output path behavior

- **Windows:** `$env:USERPROFILE\Documents\Nitrogen`
- **Linux:** `$env:HOME/Documents/Nitrogen`

## ⚙️ Configuration File

Nitrogen supports layered JSON configuration for non-secret settings:

- Global: `~/.nitrogen/config.json`
- Local (project): `./.nitrogen/config.json`
- Optional explicit overlay: `-ConfigPath <path>`

Precedence (highest to lowest):

1. Command parameters
2. Project config (`./.nitrogen/config.json`)
3. Global config (`~/.nitrogen/config.json`)
4. Built-in defaults

Example config:

```json
{
  "version": 1,
  "defaults": {
    "profile": "default",
    "provider": "OpenAI",
    "maxItems": 100
  },
  "profiles": {
    "default": {
      "provider": "OpenAI",
      "prompt": "diagnostics.default",
      "providers": {
        "OpenAI": {
          "endpoint": "https://api.openai.com/v1/responses",
          "filesEndpoint": "https://api.openai.com/v1/files",
          "model": "gpt-5",
          "apiKeyRef": "nitrogen/default/openai/api_key"
        }
      }
    }
  },
  "prompts": {
    "diagnostics.default": "Analyze diagnostics and return concise, actionable findings."
  }
}
```

> Security note: do not store plaintext `apiKey` values in config files. Nitrogen rejects plaintext API key entries in config.

## 🔐 API Key / Secret Configuration

You can pass `-ApiKey` directly, or set environment variables:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY` (for Claude)
- `AZURE_OPENAI_API_KEY`
- `AZURE_OPENAI_ENDPOINT` (for Azure OpenAI)
- `GEMINI_API_KEY`
- `PERPLEXITY_API_KEY`

Or use SecretManagement and reference a secret name via `apiKeyRef`:

```powershell
Install-Module Microsoft.PowerShell.SecretManagement -Scope CurrentUser
Install-Module Microsoft.PowerShell.SecretStore -Scope CurrentUser

Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
Set-Secret -Name "nitrogen/default/openai/api_key" -Secret "<your-api-key>"
```

Bootstrap both config and secrets interactively:

```powershell
Initialize-NitrogenConfig -ConfigureSecretVault -SetSecrets
```

Prompt helpers:

```powershell
# Show local config only
Get-NitrogenConfig -Scope Local

# Update local prompt and assign it to a profile
Set-NitrogenPrompt -Scope Local -Key diagnostics.brief -Prompt "Summarize only urgent issues." -ProfileName default
```

## Known Issues

- Tested against Gemini, OpenAI and Claude so far.
- File integration not yet enabled on AzureOpenAI or Perplexity
- Model queries only ready for Gemini, Perplexity, OpenAI

## Change/Revision History

- See [Change Log](/changelog.md)

## Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest enhancements
- Improve provider handling and diagnostics coverage
- Improve docs and examples
- Submit pull requests

Please open an [issue](https://github.com/Skatterbrainz/Nitrogen/issues) or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Author

**David Stein**

- GitHub: [@Skatterbrainz](https://github.com/Skatterbrainz)
