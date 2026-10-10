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
- API Keys stored as Environment Variables (see [API Key Configuration](#-api-key-configuration))
- Optional on Linux: [`linuxtools`](https://github.com/Skatterbrainz/LinuxTools) module for richer Linux-specific diagnostics
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

# Collect event log and services diagnostics to default path
Invoke-AIDiagnostics -Scope EventLog,Services

# Return diagnostics as objects
Invoke-AIDiagnostics -Scope Processes,Disk,Memory,System -PassThru

# Return diagnostics as JSON text
Invoke-AIDiagnostics -Scope EventLog,Services -PassThru -JSonOutput

# Submit diagnostics to OpenAI
Invoke-AIDiagnostics -Scope EventLog,Services,System -SubmitPrompt -Provider OpenAI
```

### Default output path behavior

- **Windows:** `$env:USERPROFILE\Documents\Nitrogen`
- **Linux:** `$env:HOME/Documents/Nitrogen`

## 🔐 API Key Configuration

You can pass `-ApiKey` directly, or set environment variables:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY` (for Claude)
- `AZURE_OPENAI_API_KEY`
- `AZURE_OPENAI_ENDPOINT` (for Azure OpenAI)
- `GEMINI_API_KEY`
- `PERPLEXITY_API_KEY`

## Known Issues

- Tested against Gemini, OpenAI and Claude so far.
- File integration not yet enabled on AzureOpenAI or Perplexity
- Model queries only ready for Gemini, Perplexity, OpenAI
- Endpoints are currently hard-coded

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
