---
name: grok-ui-zh
description: >
  Full-pass Chinese localization for the open-source Grok Build TUI (xai-grok-pager).
  Use when the user asks for Grok CLI UI 汉化, 继续汉化, fork grok-build 中文, or
  /grok-ui-zh. Light string replacement only — no i18n framework. Records every
  change for reuse; builds only via GitHub Actions (never local cargo on weak PCs).
---

# Grok UI 汉化（可复用技能）

## 落盘文档（先读）

| 文件 | 用途 |
|------|------|
| `references/PLAN.md` | **完整执行方案**（关卡/命令/验收/回滚） |
| `references/GATES.md` | 关卡勾选板 G0–G7 |
| `references/CHANGELOG.md` | 历史 diff 摘要 |
| `D:\grok-cli\workspace\PLAN-grok-ui-zh.md` | 工作区入口（链到本方案） |
| `D:\grok-cli\workspace\HANDOFF-grok-ui-zh.md` | 跨会话交接 |
| `D:\grok-cli\workspace\ui-zh-demo\gates.json` | 关卡状态机 |
| `D:\grok-cli\workspace\ui-zh-demo\remaining-en.csv` | 剩余英文行级清单 |

触发「继续汉化」时：**读 PLAN + GATES + HANDOFF + 最新 remaining-en.csv**，按当前 `next` 关执行，禁止另起挤牙膏路径。

## 硬规则

1. **只做 UI 文案中文**，不做完整 i18n 框架。
2. **禁止删除/覆盖用户仓库原有内容**；只在 fork 的**新分支**（默认 `ui-zh`）叠加提交；不 force-push、不改 `main` 历史。
3. **本机禁止 `cargo` 编译**（弱机）；只改源码 + GitHub Actions 出 Windows 包。
4. **编译前必须先出模拟 TUI 演示页**（`ui-zh-demo/index.html` 一类），展示 `/` 命令条、底部快捷键、模型旁权限等级；用户确认后再 push/CI。
5. **演示页 = 真实文案布局模拟**，不要做成进度统计页忽悠完成度。
6. 不恢复费用 hook；不动 GameViewer。

## 仓库与路径

| 项 | 值 |
|----|-----|
| 上游 | `https://github.com/xai-org/grok-build` |
| 用户 fork 示例 | `https://github.com/gzy3894-png/grok-build` |
| 本地 clone | `D:\grok-cli\workspace\grok-build` |
| remote | `origin`=fork，`upstream`=xai-org |
| 分支 | `ui-zh` |
| 二进制替换 | 备份后替换 `D:\grok-cli\bin\grok-app.exe`；占用则写 `grok-app-zh.exe` |
| 演示 | `D:\grok-cli\workspace\ui-zh-demo\` |

## 改法总原则

- **canonical / wire id 不改**（如 `always-approve`、`auto`、`ask` 作为配置键）。
- **只改用户可见**：`display`、`label`、`description`、`PromptFlag.text`、状态行字面量、modal 标题等。
- **UTF-8 无 BOM** 写回 `.rs` 文件。
- 优先改 **非 test** 路径；测试里 assert 英文文案会失败，全量时再对齐或放宽。
- 每轮改动写入 `references/CHANGELOG.md`（本技能目录），便于复用与审计。

## 反挤牙膏（强制）

**禁止**「发现一处改一处 → 演示 → 编译 → 用户再报漏点」。  
那是旧路径，原因是：扫不全、故意留尾巴、演示/exe 与 tip 不同步。

### 新关卡：清单驱动 · 按表面整关

| 关卡 | 规则 |
|------|------|
| **清单先行** | 每轮开工先跑 `scripts/inventory-ui.ps1`，产出 `ui-zh-demo/inventory-v2.json` + `remaining-en.csv` |
| **按表面清零** | 一次只打通 **一个用户表面**（如「欢迎全流程」「仪表盘空态」「状态行工具前缀」），该表面 **P 级 EnRemaining→0** 才算过关 |
| **禁止留尾巴** | P0/P1 **不准**写「刻意未改 / 下轮」；要跳过必须写进清单 `Status=skip` 并写清理由（wire id / 主题名 / 键位 chord） |
| **关卡验收** | 改完再跑 inventory；P0 剩余 >0 **禁止** push/CI；P1 同理除非用户书面放行 |
| **演示=清单子集** | 演示页只展示本关已改表面 + 清单上的剩余条数，禁止理想完成态 |
| **exe 对齐 tip** | 用户在用的 `grok-app-zh.exe` 必须标注对应 SHA；旧包不算「已汉化」 |

### 为什么旧方案像挤牙膏

1. **扫描面过窄**：旧 `scan-ui-en.ps1` 只盯 9 个路径，漏掉 `app_view` / `agent_view/render` / `dashboard/*` / welcome 深路径。  
2. **计数器是噪声**：`Enish` 把测试 assert、主题名 `Tokyo Night`、内部 panic 文案算进去，真漏点反而被淹没。  
3. **字段半截改**：`label/description` 改了，`format!`/`Span` 字面量、空态、工具前缀（`Web search:`）没进清单。  
4. **快捷键帮助假完成**：`shortcuts_help` 分类中文了，但 `ActionDef.long_help` **全是 None**，Enter 详情只能回落到短 description——看起来「还有英文注释」。  
5. **批次故意截断**：CHANGELOG 写「下轮 long_help / toast」= 主动制造下一管牙膏。  
6. **产物滞后**：源码已汉化、用户仍跑第一轮 exe，体感永远是「又漏了」。

## 模块地图（用户表面 → 文件）

按 **表面** 排期，不按「随手 grep 到哪改到哪」：

| 优先级 | 表面（用户看到什么） | 路径 |
|--------|----------------------|------|
| P0 | 状态行 / 思考 / 回合结束 | `views/turn_status.rs`, `scrollback/blocks/{session_event,thinking}.rs`, `tool/hook.rs` |
| P0 | 底部快捷键 + 帮助弹窗 | `actions/defaults.rs`（**含 long_help**）, `views/shortcuts_help.rs` |
| P0 | 聊天/仪表盘 chrome | `app/agent_view/render.rs`, `views/dashboard/{render,peek,row}.rs` |
| P0 | `/` 命令描述 | `slash/commands/*.rs` |
| P1 | 设置页 | `settings/defs.rs` |
| P1 | 欢迎 / 登录 / 信任目录 | `views/welcome/mod.rs` |
| P1 | 权限弹窗 | `views/permission_view.rs` + workspace `prompter.rs` |
| P1 | 会话对话框 / 标题 | `app/app_view.rs`, `dispatch/session/*`, `notifications/title.rs` |
| P2 | 上下文面板、toast、次要空态 | `context_info.rs` 等 inventory 扫出的剩余 |

## 标准工作流

```text
1. 读 PLAN.md + GATES.md + HANDOFF + CHANGELOG
2. 确认 fork 的 ui-zh；origin → 用户 fork
3. inventory-ui.ps1 → remaining-en.csv（本轮唯一真相源）
4. 按 GATES 当前 next 关（默认 G1→G2→…）整表面清零
5. 再跑 inventory；该关 Surface EnRemaining=0；更新 gates.json / GATES.md
6. 更新演示页（真实布局 + 清单剩余数）
7. 用户确认演示
8. commit + push ui-zh（不碰 main）→ Actions
9. 下载 artifact；备份后装 exe；HANDOFF + gates 写 SHA/run-id
```

关卡定义与命令全文见 `references/PLAN.md`，勿在会话里另发明流程。

## 权限等级（模型旁小字）

显示用中文，**canonical 仍是英文**：

| 显示 | canonical | 含义 |
|------|-----------|------|
| 始终批准 | `always-approve` | YOLO |
| 自动 | `auto` | 分类器 |
| 计划 | `plan` | 计划模式优先 |
| 询问 | `ask` | 每次确认 |

改 `PromptFlag { text: "..." }` 出现处（`agent_view/render.rs`、`dashboard/peek.rs`、`dashboard/render.rs`、`app_view.rs` 欢迎页等）。

## 底部快捷键条

来自 `actions/defaults.rs` 的 `label`（短）+ 各处组装的 HintItem。目标中文示例：

`Enter:发送 | Alt+Enter:换行 | Shift+Tab:模式 | Ctrl+c:取消 | Ctrl+Enter:立即发送 | Ctrl+x:快捷键`

## Slash 命令

每个 `slash/commands/*.rs` 的 `fn description(&self) -> &str` 改为中文。  
`name()` / 命令字本身（`quit`、`help`）**保持英文**以便输入。

## Windows CI 注意

- 仓库 `bin/protoc` 是 **dotslash**，Windows 上不能当 PE 执行。
- Workflow 应安装官方 `protoc-*-win64.zip`，设 `PROTOC=...\protoc.exe`，并暂时挪开 `bin/protoc`。
- `xai-proto-build` 在 Windows 上不能用 `/dev/stdout` 作 `--dependency_out`，需 temp 文件路径（fork 内可修）。

## 脚本

- `scripts/inventory-ui.ps1` — **主工具**：清单驱动，输出 `inventory-v2.json` + `remaining-en.csv`；`-FailOnRemaining` 作关卡门
- `scripts/scan-ui-en.ps1` — 旧粗扫（仅参考，不再当验收）
- `scripts/export-slash-zh.ps1` — 导出 slash description 到演示用 `slash-data.js`

## 触发语

`继续汉化` / `Grok UI 汉化` / `/grok-ui-zh` / `编译汉化包`
