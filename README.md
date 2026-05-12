# matcra587/homebrew-tap

Homebrew tap for personal CLI tools.

## Formulae

| Formula | Description |
|---------|-------------|
| `pagerduty-client` | PagerDuty API client and CLI |
| `peerscout` | Fetch live peers for Cosmos SDK chains |
| `slick` | Headless Slack CLI for agents, scripts, and CI jobs |

## Install

```bash
brew install matcra587/tap/<formula>
```

Or tap first:

```bash
brew tap matcra587/tap
brew install <formula>
```

Build from source:

```bash
brew install --HEAD matcra587/tap/<formula>
```

## Brewfile

```ruby
tap "matcra587/tap"
brew "<formula>"
```
