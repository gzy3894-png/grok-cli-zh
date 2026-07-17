# Grok UI 汉化改动记录

## 2026-07-17 — PLAN 关卡 G0–G7 整包清零（待演示确认后一次 CI）

### 流程

按 `references/PLAN.md` + `workspace/PLAN-grok-ui-zh.md`：inventory → 整关 → inventory。  
**未 push**；用户确认演示后再一次云端编译。

### Inventory

| 时点 | Remaining EN |
|------|----------------|
| 开工基线 | 154–155（P0≈101） |
| 本关结束 | **0**（P0=0 P1=0 P2=0） |

### 关卡

| 关 | 摘要 |
|----|------|
| G0 | session_event/thinking/hook 扫尾 |
| G1 | agent_view + dashboard chrome + 161+ HintItem 中文 |
| G2 | defaults **55** 条中文 `long_help`（None=0） |
| G3 | slash description/诊断中文；`/cmd` 保留 |
| G4–G6 | welcome / permission / app_view / lifecycle / fork |
| G7 | context_info 缺字：`·`→`\|`、双空格、display-width |

### 另

- 图片元数据、Skills→技能、底栏发送/换行/模式（前序会话）
- `inventory-ui.ps1` 噪声：测试 assert、`/cmd` 脚手架、CLI flag、占位 format

---

## 2026-07-17 — 缺字漏字根因修复 + 截图表面补全

### 用户反馈

截图：`终批准` / `闲` / `具调用` / `缩次数` / `剩`；欢迎页/上下文/图片预览仍有英文。

### 根因（缺字）

源码与 `grok-app-zh.exe` 均为完整「始终批准 / 空闲 / 工具调用 / 压缩次数 / 约剩」。  
U+00B7 间隔号 `·` 与空心菱形/圆 `◇/○` 为 **East Asian Ambiguous** 宽度：`unicode-width` 计 1 列，中文 Windows 字体常画 2 列 → 挤掉后续汉字首字。

### 修复

| 文件 | 改动 |
|------|------|
| `context_info.rs` | 分隔符 `·` → ASCII ` \| `；图例 glyph 后双空格；label 按 **display width** 对齐 |
| `prompt_widget/mod.rs` | 模型旁 flag 分隔符同改 ` \| `（避免 `始终批准` 显示成 `终批准`） |
| `acp_types.rs` | `Skills`→`技能`，`MCP servers`→`MCP 服务器`；`count_detail` 支持中文名词 |
| `context_info.rs` | 工具明细名词 `tool`→`工具` |
| `image_overlay.rs` | 格式/尺寸/大小/路径/预览状态中文 |
| `welcome/mod.rs` + `hero_box.rs` | 登录文案、更新日志标题、新建工作树 |
| `views/agent.rs` | 底栏：发送/排队/立即发送/换行/模式/接受建议… |

### 测试对齐

- `usage_categories_tests`、`image_overlay/tests`、`context_info` 单测、`agent` hint 断言、pty 图片预览

### 未 push / 未 CI

演示确认后再 commit + Actions；本机仍禁 cargo。

---

## 2026-07-17 — 方案升级：清单驱动（反挤牙膏）

### 问题

用户反馈 UI/快捷键注释仍漏点，体感「每次挤牙膏」。根因不是某一串没改，而是流程：

1. 旧扫描只覆盖 ~9 路径，漏 `agent_view/render`、`dashboard/*`、`app_view`、welcome 深路径  
2. `Enish` 噪声计数掩盖真漏点  
3. 字段半截改（label 有、format!/空态/工具前缀无）  
4. `long_help` 全 None → 快捷键详情只有短 description  
5. CHANGELOG「刻意未改 / 下轮」= 主动截断  
6. 旧 exe 与 tip 不同步

### 改动（技能/工具，非产品字符串本轮）

| 文件 | 内容 |
|------|------|
| `scripts/inventory-ui.ps1` | 清单驱动；输出 `inventory-v2.json` + `remaining-en.csv` |
| `SKILL.md` | 反挤牙膏关卡：按表面清零、P0/P1 禁留尾巴、inventory 验收 |

### 基线（本轮 inventory）

- Remaining EN：**155**（P0=101 / P1=53 / P2=1）  
- 已清零表面：`defaults` label/desc、`settings` label/desc、`turn_status`（字段层）、`notifications/title`  
- 主要尾巴：`agent_view/render`、`slash` 噪声、`dashboard/*`、`welcome`、`app_view`、`permission_view`

### 下一关建议（整表面，不挤牙膏）

1. **P0 chrome**：`agent_view/render` + `dashboard/{render,peek,row}` 一次清零  
2. **P0 快捷键深度**：给高频 ActionDef 补中文 `long_help`（现在全 None）  
3. **P1 welcome + permission** 一次清零  
4. inventory `-FailOnRemaining` 过关后再演示/CI

---

## 2026-07-17 — 方案全文落盘

用户要求「把这些方案落盘」。已写入可复用路径（非仅会话口述）：

| 落盘路径 | 内容 |
|----------|------|
| `references/PLAN.md` | 完整执行方案（目标/约束/G0–G7/命令/验收/回滚） |
| `references/GATES.md` | 关卡勾选板 |
| `SKILL.md` | 顶部「落盘文档」索引 + 工作流改指 PLAN |
| `workspace/PLAN-grok-ui-zh.md` | 工作区入口 |
| `workspace/HANDOFF-grok-ui-zh.md` | 交接对齐方案 |
| `workspace/ui-zh-demo/gates.json` | 关卡状态机 |
| `workspace/ui-zh-demo/PLAN.md` | 演示目录说明 |
| `workspace/ui-zh-demo/todo.csv` | 与 GATES 对齐的待办 |
| `scripts/inventory-ui.ps1` | 清单工具（既有） |

**当前 next 关：G1（P0 chrome）。**

---

## 2026-07-16 — 第二轮（源码，待 CI）

### 已在第一轮 CI（`ui-zh` @ da9a871 一带）

| 文件 | 改动摘要 |
|------|----------|
| `scrollback/blocks/session_event.rs` | 耗时/回合完成/取消/失败/压缩/登录提示等中文 |
| `scrollback/blocks/tool/hook.rs` | `[钩子: ` |
| `acp/tracker.rs` | Waiting 标签中文 |
| `views/turn_status.rs` | 状态行中文（思考中/运行/停止/监视中/排队…） |
| `scrollback/blocks/context_info.rs` | 上下文面板标题与图例 |
| `views/welcome/mod.rs` | 欢迎菜单中文 |
| `views/dashboard/row.rs` | `新会话` |
| `notifications/title.rs` | 窗口标题活动文案 |
| `actions/defaults.rs` | 部分快捷键中文 |
| `.github/workflows/build-windows.yml` | Windows 远程构建 |
| `crates/build/xai-proto-build/src/lib.rs` | Windows protoc deps 路径 |

### 本轮工作区（第二轮，提交时合并）

| 文件 | 改动摘要 |
|------|----------|
| `slash/commands/*.rs`（约 59 文件） | 全部 `description()` 中文 |
| `actions/defaults.rs` | 剩余 label/description 中文（导航/回合/滚动/仪表盘等） |
| `settings/defs.rs` | 权限模式选项 + 大量 settings label 中文 |
| `app/app_view.rs` | 欢迎页 flag `始终批准` |
| `app/agent_view/render.rs` | 聊天提示 flag：始终批准/自动/计划 |
| `views/dashboard/peek.rs` | 同上 |
| `views/dashboard/render.rs` | 仪表盘派发模式 flag |
| `xai-grok-workspace/.../prompter.rs` | `始终允许：` |

### 刻意未改

- 命令名 `/quit` `/help` 等英文 token
- `PermissionModeKind::as_canonical()` 的 wire 字符串
- 测试里大量英文 assert（后续单独对齐）
- `shortcuts_help.rs` 全文、权限弹窗全部细节、部分 settings description 长文

### 产物

- 第一轮 artifact：`grok-app-zh.exe`（残缺相对全量目标）
- 第二轮：push 后重新 CI

## 复用检查清单

- [ ] 扫描 P0–P2 模块
- [ ] 更新 `ui-zh-demo` 模拟页
- [ ] 用户确认
- [ ] 只推 `ui-zh`
- [ ] Actions 成功
- [ ] 备份后装 exe
- [ ] 本 CHANGELOG 追加条目

## 2026-07-16 — 第三轮：上游 force 更新 + Thought 漏点

- 上游 `main` 从 `b189869` **force** 到 `c68e39f`（无关历史，不能普通 merge）
- 策略：从 `upstream/main` 重建 `ui-zh`，cherry-pick 三枚汉化提交
- 本地备份分支：`ui-zh-pre-upstream-20260716`（旧 tip）
- 冲突：`settings/defs.rs` collapsed_edit_blocks；`screen_mode_switch.rs` 描述
- **漏点修复**：`thinking.rs` `Thought for Xs` → `已思考 Xs`；`Thinking…` → `思考中…`
- 推送：`ui-zh` 需 force-with-lease（仅功能分支，不碰用户其它仓/main 默认保护）

## 2026-07-16 — CI 状态核对

| Run | SHA | 结果 | 说明 |
|-----|-----|------|------|
| 29466562186 | `da9a871`（旧 tip，重建前） | **success** | 第一轮+部分快捷键；本地 `dist/grok-app.exe` / `bin/grok-app-zh.exe` 即此产物 |
| 29482083684 | `2f26778`（重建后 tip） | **failure** | `dashboard.rs` 结构损坏：`pub struct`/`fn name` 被中文描述覆盖 |
| 29486269344 | `5daf77d`（dashboard 修好） | **failure** | 编译通过，**链接**挂：`LNK4319` PDB public-symbol limit |
| 29488238566 | `1224fc8`（`CARGO_PROFILE_RELEASE_DEBUG=0`） | **failure** | 仍 ~42m 后死在 link；env 覆盖**未真正关掉** MSVC `/DEBUG` |

### 根因（29488238566 / 29486269344）

```
error: linking with link.exe failed: exit code: 4319
LNK4318: Very long symbol name … debug information
LINK : fatal error LNK4319: A PDB limit was hit while adding public symbols
could not compile xai-grok-pager-bin (bin xai-grok-pager)
```

- 不是汉化字符串语法问题（dashboard 修好后仍挂在 link）
- workspace 默认 `--release` 虽无 `debug=1`，但 MSVC 仍会生成 PDB；仅靠 `CARGO_PROFILE_RELEASE_*` 不够

### 修复（待 push）

- `Cargo.toml`：`[profile.release-win]` — `debug=0` / `strip=symbols` / 无 PDB 侧写
- workflow：`cargo build --profile release-win` + `RUSTFLAGS=-C debuginfo=0 -C strip=symbols -C link-arg=/DEBUG:NONE`
- 产物路径：`target/release-win/xai-grok-pager.exe`；cache key  bump 防脏对象

### 修复（已做）

- 恢复 `slash/commands/dashboard.rs` 的 `DashboardCommand` + `name()`，保留中文 `description()`
- 本地 `dist/` 与 tip **不一致**：仍是成功 run 的旧包，**不含** slash/settings 全量第二轮

## 2026-07-16 — 第四轮：shortcuts / 权限 / 设置扫尾 + CI 待 push

### 源码（工作区，未 commit 时可一起提交）

| 文件 | 改动摘要 |
|------|----------|
| `views/shortcuts_help.rs` | 分类名、标题「键盘快捷键」、页脚、粘贴说明、搜索/粘贴伪行 |
| `actions/defaults.rs` | 剩余英文 label → 中文（麦克风/模型/仪表盘/固定…） |
| `settings/defs.rs` | enum display + 几乎全部 description 中文；语言名保留英文 |
| `xai-grok-workspace/.../prompter.rs` | 权限选项：是/否/始终允许/永不允许/始终批准模式等 |
| `permission_cursor.rs` | 默认选中权限四项 display 中文 |
| `dispatch/session/lifecycle.rs` + `fork.rs` | 新会话/分支/worktree 本机问询弹窗 |
| `memory_cmd.rs` | 工作区/全局记忆标签 |
| `Cargo.toml` + `build-windows.yml` | `profile.release-win` + RUSTFLAGS `/DEBUG:NONE` |

### 演示

- `ui-zh-demo/index.html` 增加诚实进度表（非理想完成态）
- `module-stats.json` / `done.csv` / `todo.csv` 同步

### 刻意未改 / 下轮

- `ActionDef.long_help` 大段英文（快捷键详情页正文）
- 测试 assert 英文夹具
- docs 用户指南标题
- **未 push、未触发 CI**（等用户确认演示）

### 用户可见进度（粗估）

- 高频路径（状态行、slash、设置 label、权限选项、底部快捷键）：约 **70–80%**
- 含 long_help / 文档 / 测试噪声的「全量字符串」：约 **45–55%**

