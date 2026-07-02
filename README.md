# BooBoo

[![CI](https://github.com/krishnasureshcpa/BooBoo/actions/workflows/ci.yml/badge.svg)](https://github.com/krishnasureshcpa/BooBoo/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14.0+-black?logo=apple)](Package.swift)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](Package.swift)
[![GitHub Release](https://img.shields.io/github/v/release/krishnasureshcpa/BooBoo?include_prereleases&sort=semver)](https://github.com/krishnasureshcpa/BooBoo/releases)

> Your friendly macOS ghost who keeps your Mac clean, compliant, and out of trouble.

BooBoo is a privacy-first, local-only security compliance tool for macOS. It checks 50+ CIS Level 1 benchmarks, explains what each one means, and helps you fix what matters. No telemetry. No cloud. No noise.

```shell
brew install booboo   # coming soon
booboo scan           # check your Mac's security posture
booboo fix --all      # remediate everything at once
```

---

## Features

| What | How |
|------|-----|
| CIS L1 compliance | 50+ rules covering encryption, firewall, sharing, auth, updates |
| Local-first | Zero network access. Your data stays on your Mac. |
| Two interfaces | Native SwiftUI app **and** a terminal CLI |
| Guided remediation | Each fix explains what it does before applying |
| Dark mode | Because ghosts prefer the dark |

## Quick Start

```shell
# Clone
git clone https://github.com/krishnasureshcpa/BooBoo.git
cd BooBoo

# Build the CLI
swift build --product booboo

# Run your first scan
swift run booboo scan

# Build the GUI
swift build --product BooBooGUI
open .build/debug/BooBooGUI.app
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   BooBooGUI                     │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐  │
│  │Dashboard │ │Compliance│ │  Settings      │  │
│  │ Score    │ │ Rules    │ │  Preferences   │  │
│  │ Overview │ │ Search   │ │  About/License │  │
│  └────┬─────┘ └────┬─────┘ └───────┬────────┘  │
└───────┼─────────────┼───────────────┼───────────┘
        │             │               │
┌───────┼─────────────┼───────────────┼───────────┐
│       │    BooBooCore (shared)      │           │
│  ┌────▼─────────┐ ┌─▼──────────────▼──┐        │
│  │  RuleEngine  │ │ RemediationService │        │
│  │ load/run     │ │ remediate()        │        │
│  │ evaluate()   │ │ confirm()          │        │
│  └────┬─────────┘ └────┬──────────────┘        │
│       │                │                        │
│  ┌────▼────────────────▼──────────────────┐    │
│  │        50 YAML CIS L1 Rules            │    │
│  │  5 probe types: password, system,      │    │
│  │  sharing, file_system, launch          │    │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
        │
┌───────▼─────────────────────────────────────────┐
│            BooBooCLI                           │
│  booboo scan / booboo fix / booboo status       │
│  booboo report --format json                    │
└─────────────────────────────────────────────────┘
```

## Project Structure

```
BooBoo/
├── Sources/
│   ├── BooBooCore/       # Shared engine: rules, probes, remediation
│   ├── BooBooCLI/        # Terminal interface (ArgumentParser)
│   └── BooBooGUI/        # Native SwiftUI app
├── rules/cis-l1/         # 50 YAML rule definitions
├── scripts/              # Build helpers
├── Design/               # Design assets
└── Tests/                # Unit tests
```

## Development

```shell
# Build all targets
swift build

# Run tests
swift test

# Type-check (macOS only)
bun typecheck
```

### Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+ or Swift 5.9+ toolchain
- No CocoaPods, no Carthage — pure SPM

## Contributing

BooBoo is open source and welcomes contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) to get started. Keep it simple, keep it local, and no emojis in the code.

## Security

Found a vulnerability? See [SECURITY.md](SECURITY.md) for our disclosure policy. Please do not open public issues for security bugs.

## License

MIT. See [LICENSE](LICENSE) for details.

---

*Built with ghostly precision by [krishnasureshcpa](https://github.com/krishnasureshcpa)*
