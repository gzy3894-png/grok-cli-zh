# Grok CLI Chinese Localization

> [中文](README.md) | **English**

[![Release](https://img.shields.io/badge/release-v1.0.0-blue)](https://github.com/gzy3894-png/grok-cli-zh/releases/tag/v1.0.0)
[![Upstream](https://img.shields.io/badge/upstream-xai--org%2Fgrok--build-111827)](https://github.com/xai-org/grok-build)
[![Platform](https://img.shields.io/badge/platform-windows%20amd64-0f766e)](./README.en.md)
[![License](https://img.shields.io/badge/license-Apache%202.0-green)](./LICENSE)
[![LINUX DO](https://img.shields.io/badge/LINUX%20DO-community-0066cc)](https://linux.do/)

**Grok CLI 汉化** is a Chinese UI localization package for the open-source [Grok Build](https://github.com/xai-org/grok-build) terminal agent (`xai-grok-pager` / Grok coding TUI).

It ships two things:

1. **Ready-to-run Windows binary** with Chinese UI strings
2. **Reusable localization skill** (inventory-driven, gate-based) so you can re-localize after upstream updates

In short: user-visible copy only — no full i18n framework, no wire-id / config-key renames.

## Why it exists

Upstream Grok Build is an English TUI. Day-to-day friction includes:

- Footer shortcuts, help modals, and `/` command descriptions in English
- Permission modes next to the model name hard to scan at a glance
- Welcome, settings, permission prompts, and tool-status prefixes mixed language
- CJK ambiguous-width glyphs on Chinese Windows can clip characters (e.g. 「始终批准」 showing as 「终批准」)

This repo localizes those **user-facing surfaces** and fixes related display-width issues.  
**Command names** (e.g. `/quit`) and **canonical config values** (e.g. `always-approve`) stay English for typing and config compatibility.

## Community

This open-source project is linked with and acknowledges the [LINUX DO community](https://linux.do/).

Questions, install issues, and improvement ideas are welcome in GitHub Discussions:

```text
https://github.com/gzy3894-png/grok-cli-zh/discussions
```

Thanks also to Linux Do community feedback around Grok / CPA / CLI practice.

## Ecosystem

| Component | Role |
| --- | --- |
| [xai-org/grok-build](https://github.com/xai-org/grok-build) | Upstream source (Apache-2.0) |
| [gzy3894-png/grok-build](https://github.com/gzy3894-png/grok-build) `ui-zh` branch | Localized source branch (this release: tip `d897b03`) |
| [gzy3894-png/grok-quota](https://github.com/gzy3894-png/grok-quota) | Same author: CPA Grok quota observation plugin |
| Local Grok / portable install | Replace or side-by-side run `grok-app.exe` from Releases |

### Boundaries

| Capability | This repo |
| --- | --- |
| Chinese UI copy (status / shortcuts / slash / settings / welcome…) | **Yes** |
| Windows amd64 prebuilt binary | **Yes** |
| Inventory-driven localization skill & gates | **Yes** |
| Full i18n framework / runtime language switch | **No** |
| Changing wire ids / config keys / command names | **No** |
| Official xAI release channel | **No** |

## Install

### Option A: GitHub Release (recommended)

1. Open [Releases](https://github.com/gzy3894-png/grok-cli-zh/releases)
2. Download the latest **Windows amd64** zip (e.g. `grok-cli-zh-windows-amd64.zip`)
3. Extract `grok-app.exe`
4. **Back up** your current binary, then replace (or run side-by-side)

```text
backup:  <your>\grok-app.exe  →  <your>\backup\
replace: extracted grok-app.exe →  <your>\grok-app.exe
```

5. Launch as usual. Auth, sessions, skills, and MCP behave like upstream; only UI strings are Chinese.

> Public release currently targets **Windows x64**. Other platforms: build from the `ui-zh` branch.

### Option B: Build from localized source

```text
https://github.com/gzy3894-png/grok-build/tree/ui-zh
```

Prefer GitHub Actions for Windows artifacts.

Build fingerprint for this release:

| Item | Value |
| --- | --- |
| Source tip | `d897b03` |
| Gates | G0–G7 clear (inventory Remaining EN = 0) |
| SHA256 | `3E4995C11C122A09D6C3500DA3D469FAA367E1CEEA6832FE0A5CB83A77E03B34` |
| Approx size | ~131.5 MB |

## Localization skill

The `skill/` directory is the reusable **Grok UI 汉化** skill:

| Path | Purpose |
| --- | --- |
| `skill/SKILL.md` | Agent contract & hard rules |
| `skill/references/PLAN.md` | Full execution plan |
| `skill/references/GATES.md` | Gates G0–G7 |
| `skill/references/CHANGELOG.md` | Diff history |
| `skill/scripts/inventory-ui.ps1` | Inventory scanner (source of truth) |

Workflow: inventory → clear one user surface per gate → re-inventory → demo confirm → CI.  
No half-field “leave for next round” patches on P0/P1.

Copy into your Grok skills directory; triggers include `继续汉化` / `/grok-ui-zh`.

## Demo page

`demo/index.html` is a layout mock of localized surfaces for pre-release visual check — not a progress dashboard.

## Version

| Item | Value |
| --- | --- |
| Repo | `grok-cli-zh` (Grok CLI 汉化) |
| Version | `v1.0.0` |
| Based on tip | `d897b03` |
| Primary platform | Windows amd64 |
| License | Derivative binary: Apache-2.0; see LICENSE + NOTICE |

## Non-goals

- Not an official xAI / SpaceXAI release channel
- Not a full multi-language i18n framework
- Does not restore fee hooks or modify GameViewer
- Does not upload accounts, secrets, or session content to third parties

## Thanks

- [xai-org/grok-build](https://github.com/xai-org/grok-build) — upstream Grok Build / TUI
- [gzy3894-png/grok-quota](https://github.com/gzy3894-png/grok-quota) — companion CPA quota plugin
- [LINUX DO community](https://linux.do/) — community recognition and feedback

## License

Upstream [Grok Build](https://github.com/xai-org/grok-build) is **Apache License 2.0**. Prebuilt binaries here are derivatives with Chinese UI string changes and follow Apache-2.0; see [LICENSE](./LICENSE) and [NOTICE](./NOTICE).
