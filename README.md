# Grok CLI 汉化

> **中文** | [English](README.en.md)

[![Release](https://img.shields.io/badge/release-v1.0.0-blue)](https://github.com/gzy3894-png/grok-cli-zh/releases/tag/v1.0.0)
[![Upstream](https://img.shields.io/badge/upstream-xai--org%2Fgrok--build-111827)](https://github.com/xai-org/grok-build)
[![Platform](https://img.shields.io/badge/platform-windows%20amd64-0f766e)](./README.md)
[![License](https://img.shields.io/badge/license-Apache%202.0-green)](./LICENSE)
[![LINUX DO](https://img.shields.io/badge/LINUX%20DO-社区认可-0066cc)](https://linux.do/)

Grok CLI 汉化是给开源 [Grok Build](https://github.com/xai-org/grok-build)（也就是终端里的 `xai-grok-pager` / Grok 编码代理 TUI）做的**界面中文包**。

它做的事情很直接：

1. **现成 Windows 可执行文件**：装上就能用中文界面
2. **可复用汉化技能**：清单驱动、关卡制，方便跟上游同步后再汉化一轮

一句话：只改你看得见的 UI 文案，不搞完整 i18n 框架，也不动协议/配置键名。

## 它解决什么问题

官方 Grok Build 是英文 TUI。日常用下来，这些地方最影响手感：

- 底部快捷键、帮助弹窗、`/` 命令说明全是英文
- 权限模式（始终批准 / 自动 / 询问）写在模型名旁边，一眼不好扫
- 欢迎页、设置、权限确认、状态行工具前缀，中英文混着很割裂
- 中文 Windows 下个别「东亚宽度」字符还会把字挤没（例如「始终批准」看起来像「终批准」）

本仓库把这些**用户可见表面**做成中文，并修了 CJK 宽度相关的显示问题。  
**命令字**（如 `/quit`）和**配置 canonical 值**（如 `always-approve`）保持英文，方便输入和兼容配置。

## 社区

本开源项目已链接并认可 [LINUX DO 社区](https://linux.do/)。

使用方法、安装排错和改进建议，欢迎在 GitHub Discussions 交流：

```text
https://github.com/gzy3894-png/grok-cli-zh/discussions
```

也感谢 Linux Do 社区对 Grok / CPA / CLI 实践与反馈的支持。

## 和谁配合

| 组件 | 关系 |
| --- | --- |
| [xai-org/grok-build](https://github.com/xai-org/grok-build) | 上游源码（Apache-2.0） |
| [gzy3894-png/grok-build](https://github.com/gzy3894-png/grok-build) `ui-zh` 分支 | 汉化源码分支（本成品基于 tip `d897b03`） |
| [gzy3894-png/grok-quota](https://github.com/gzy3894-png/grok-quota) | 同作者：CPA 侧 Grok 额度观测插件 |
| 本机 Grok / portable 安装目录 | 用 Release 里的 `grok-app.exe` 替换或旁路运行 |

### 范围边界（重要）

| 能力 | 本仓库是否做 |
| --- | --- |
| UI 文案中文（状态行 / 快捷键 / slash / 设置 / 欢迎…） | **是** |
| Windows amd64 预编译包 | **是** |
| 清单驱动汉化技能与关卡方案 | **是** |
| 完整 i18n 框架 / 运行时切语言 | **否** |
| 改动 wire id / 配置键 / 命令名 | **否** |
| 官方维护或替代 xAI 发行渠道 | **否** |

## 安装

### 方式一：下载 Release（推荐）

1. 打开 [Releases](https://github.com/gzy3894-png/grok-cli-zh/releases)
2. 下载最新的 **Windows amd64** 包（例如 `grok-cli-zh-windows-amd64.zip`）
3. 解压得到 `grok-app.exe`（与上游 `xai-grok-pager` 同产物，文件名便于替换）
4. **先备份**你正在用的原版 exe，再替换，例如：

```text
# 示例：portable 安装
备份:  D:\grok-cli\bin\grok-app.exe  →  D:\grok-cli\bin\backup\
替换:  解压后的 grok-app.exe        →  D:\grok-cli\bin\grok-app.exe

# 或不想覆盖：旁路运行
D:\path\to\grok-app.exe
```

5. 正常启动 Grok CLI 即可。登录、会话、技能、MCP 等逻辑与上游一致，只是界面文案是中文。

> 当前公开发布以 **Windows x64** 为主。其它平台请用 `ui-zh` 源码分支自行构建。

### 方式二：从汉化源码分支构建

源码在 fork 的 **`ui-zh`** 分支（不要动用户 `main`）：

```text
https://github.com/gzy3894-png/grok-build/tree/ui-zh
```

建议用仓库自带的 GitHub Actions 出 Windows 包；本机弱机不建议 `cargo` 全量编译。

构建指纹（本 Release 对应）：

| 项 | 值 |
| --- | --- |
| 源码 tip | `d897b03` |
| 关卡 | G0–G7 清零（inventory Remaining EN = 0） |
| SHA256 | `3E4995C11C122A09D6C3500DA3D469FAA367E1CEEA6832FE0A5CB83A77E03B34` |
| 约大小 | ~131.5 MB |

## 汉化技能（给代理 / 二次维护）

仓库内 `skill/` 是可复用的 **Grok UI 汉化技能**（原 `grok-ui-zh`）：

| 路径 | 用途 |
| --- | --- |
| `skill/SKILL.md` | 代理契约与硬规则 |
| `skill/references/PLAN.md` | 完整执行方案 |
| `skill/references/GATES.md` | 关卡 G0–G7 |
| `skill/references/CHANGELOG.md` | 历史 diff 摘要 |
| `skill/scripts/inventory-ui.ps1` | 清单扫描（真相源） |

核心原则：

- **清单先行** → **按表面整关清零** → 演示确认 → 再 CI
- 禁止「发现一处改一处」的挤牙膏式汉化
- 命令字、canonical 配置键保持英文

拷到你的 Grok skills 目录即可被触发（例如触发语：`继续汉化` / `/grok-ui-zh`）。

## 演示页

`demo/index.html` 是汉化表面的布局示意，用于发布前肉眼过一遍，**不是**进度统计页。

本地打开：

```powershell
start D:\path\to\grok-cli-zh\demo\index.html
```

## 当前版本

| 项目 | 值 |
| --- | --- |
| 仓库名 | `grok-cli-zh`（Grok CLI 汉化） |
| 版本 | `v1.0.0` |
| 基于 tip | `d897b03` |
| 主要平台 | Windows amd64 |
| 许可证 | 二进制与上游衍生：Apache-2.0；技能文档脚本：见仓库说明 |

## 非目标

- 不是 xAI / SpaceXAI 官方发行渠道
- 不做完整多语言 i18n 框架
- 不恢复费用 hook，不改 GameViewer
- 不上传账号、密钥或会话内容到第三方

## 致谢

- [xai-org/grok-build](https://github.com/xai-org/grok-build) — 上游 Grok Build / TUI
- [gzy3894-png/grok-quota](https://github.com/gzy3894-png/grok-quota) — 同作者 CPA 额度观测插件
- [LINUX DO 社区](https://linux.do/) — 社区认可与使用反馈

## License

上游 [Grok Build](https://github.com/xai-org/grok-build) 为 **Apache License 2.0**。本仓库发布的预编译包是在其源码上叠加 UI 中文修改后的衍生作品，遵循 Apache-2.0；见 [LICENSE](./LICENSE) 与 [NOTICE](./NOTICE)。

技能目录中的文档与脚本（清单工具、关卡方案等）以方便复用为目的一并提供；使用预编译包时请同时保留 NOTICE 中的归属信息。
