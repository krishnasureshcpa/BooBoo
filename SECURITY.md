# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |
| < 1.0   | No        |

## Reporting a Vulnerability

BooBoo takes security seriously. If you discover a vulnerability, please use
**GitHub's private security advisory** feature instead of opening a public issue:

1. Go to https://github.com/krishnasureshcpa/BooBoo/security/advisories
2. Click "New draft security advisory"
3. Fill in the details

You can expect an initial response within 7 days.

### What to include

- Type of vulnerability
- Steps to reproduce
- Affected versions
- Any potential impact

### Scope

- In scope: privilege escalation, data leakage, code execution, auth bypass
- Out of scope: missing CIS recommendations (open a feature request), cosmetic issues

We do not have a bug bounty program, but we will acknowledge your contribution
in release notes and credit you in our security advisory.

## Security Architecture

- **Network:** BooBoo makes zero network connections by design.
- **Storage:** No analytics, no telemetry, no crash reporting.
- **Privilege:** System changes require explicit user confirmation per action.
- **Dependencies:** Minimal. One dependency (swift-argument-parser) for the CLI. Pure SPM.
