# Grok UI 汉化 — 反挤牙膏执行方案（落盘）

> 状态：生效中（2026-07-17）  
> 触发：`继续汉化` / `/grok-ui-zh` /「按新方案清 P0 chrome」  
> 关联：`SKILL.md` · `CHANGELOG.md` · `../../../../workspace/HANDOFF-grok-ui-zh.md` · `ui-zh-demo/remaining-en.csv`

---

## 1. 目标

只做 **Grok Build TUI 用户可见文案中文**（轻量改字符串，不做 i18n 框架）。  
交付标准：用户日常路径上 **不再靠「再报一个漏点」推进**；进度以 inventory 清单为准。

**非目标：** 完整 i18n、测试英文 assert 全改、docs 全文、本机 cargo、费用 hook、GameViewer。

---

## 2. 约束

| 约束 | 说明 |
|------|------|
| 仓库 | 仅 fork `gzy3894-png/grok-build` 的分支 `ui-zh` |
| 禁止 | force-push / 改 `main` / 删用户资产 / 无备份盖 exe |
| 编译 | **仅** GitHub Actions；本机禁止 cargo |
| 演示 | 先演示后 CI；演示 = 真实布局 + 清单剩余，禁止理想完成态 |
| 键与 wire | 命令名 `/quit`、canonical `always-approve` 等 **保持英文** |

---

## 3. 为什么旧路径失败（必须记住）

1. 扫描面过窄 → 漏 chrome / welcome 深路径  
2. Enish 噪声计数 → 假进度  
3. 半截字段（label 有、format!/空态无）  
4. `long_help` 全 None → 快捷键详情假完成  
5. CHANGELOG「下轮」= 主动截断  
6. exe 与 tip 不同步 → 体感永远漏  

**禁止再走：** 发现一处改一处 → 演示 → 编译 → 用户再报漏点。

---

## 4. 新流程（关卡制）

```text
inventory 基线 → 选 1 个用户表面 → 按 CSV 整表面清零
    → 再 inventory（该表面 En=0）→ 更新演示 → 用户确认
    → commit/push ui-zh → Actions → 装 exe 写 SHA
```

| 关卡 | 规则 |
|------|------|
| 清单先行 | 开工必跑 `scripts/inventory-ui.ps1` |
| 按表面清零 | 一次一个表面；该表面 EnRemaining→0 才过关 |
| 禁留尾巴 | P0/P1 不准「刻意未改」；skip 必须写理由 |
| 验收门 | P0>0 禁止 push/CI；P1 同理除非用户放行 |
| 演示=清单 | 只展示本关真实结果 + remaining 数 |
| exe=SHA | HANDOFF 记录 `grok-app-zh.exe` ↔ commit |

---

## 5. 用户表面地图（排期唯一顺序）

| 关 ID | 优先级 | 表面 | 文件 |
|-------|--------|------|------|
| G0 | P0 | 状态行/思考/回合（基线已基本清） | `turn_status` / `session_event` / `thinking` / `hook` |
| G1 | P0 | **聊天+仪表盘 chrome** | `app/agent_view/render.rs` · `views/dashboard/{render,peek,row}.rs` |
| G2 | P0 | **快捷键深度 long_help** | `actions/defaults.rs`（补 `Some("…")`）· `shortcuts_help.rs` 边角 |
| G3 | P0 | slash 清单去噪 + 真 UI 尾 | `slash/commands/*.rs` |
| G4 | P1 | 欢迎/登录/信任目录 | `views/welcome/mod.rs` |
| G5 | P1 | 权限弹窗 | `permission_view.rs` + workspace `prompter.rs` |
| G6 | P1 | 会话对话框/标题 | `app_view.rs` · `dispatch/session/*` · `notifications/title` |
| G7 | P2 | 上下文/toast/次要空态 | inventory 剩余 |

**执行顺序：G1 → G2 → G3 → G4 → G5 → G6 → G7。**  
不得跳关半截做下一关（除非用户指定）。

---

## 6. 每关执行清单（可勾）

### 6.1 开工

```powershell
cd D:\grok-cli\workspace\grok-build
git checkout ui-zh
git status -sb
powershell -NoProfile -ExecutionPolicy Bypass -File D:\grok-cli\home\skills\grok-ui-zh\scripts\inventory-ui.ps1
```

证据：`ui-zh-demo/remaining-en.csv` 有本关 Surface 行。

### 6.2 改源码

- 只改用户可见串；UTF-8 无 BOM  
- 同一表面内：`label` / `description` / `display` / `text` / `format!` / `Span` 字面量 **一次扫完**  
- 每改一批写入 `references/CHANGELOG.md`  

### 6.3 关卡验收

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\grok-cli\home\skills\grok-ui-zh\scripts\inventory-ui.ps1
# 本关 Surface 的 EnRemaining 必须为 0
# 可选硬门：
# powershell ... inventory-ui.ps1 -FailOnRemaining
```

### 6.4 演示（CI 前）

- 更新 `ui-zh-demo/index.html`（真实布局，非理想完成态）  
- 页上写：本关名、tip/基线 remaining、本关清零表面  
- **等用户确认** 再 push  

### 6.5 发布

```powershell
# 用户确认后
git add -A
git commit -m "ui(zh): gate Gx — <surface>"
git push origin ui-zh
gh workflow run build-windows.yml --repo gzy3894-png/grok-build --ref ui-zh
# 成功后 download → 备份 → 装 grok-app-zh.exe → HANDOFF 写 SHA + run-id
```

### 6.6 回滚 / 停止

| 条件 | 动作 |
|------|------|
| inventory 本关 En 未清零 | **禁止** push |
| 用户未确认演示 | **禁止** CI |
| CI link/编译失败 | 修 CI，不回退已合入的正确中文串 |
| 误伤 wire id / 命令名 | 立即还原该字段 |
| 用户说停 | 提交已做表面到工作区，更新 HANDOFF，不 push |

---

## 7. 基线快照（2026-07-17 inventory）

```
Remaining EN: 155  (P0=101  P1=53  P2=1)
```

| Surface | En（约） | 关 |
|---------|----------|-----|
| `app/agent_view/render.rs` | 39 | G1 |
| `slash/commands` | 35（含噪声） | G3 |
| `views/dashboard/render.rs` | 20 | G1 |
| `views/welcome/mod.rs` | 25 | G4 |
| `app/app_view.rs` | 24 | G6 |
| `views/permission_view.rs` | 13 | G5 |
| `dashboard/row+peek` | ~8 | G1 |
| `actions/defaults` label | 0；**long_help 全 None** | G2 |
| `settings/defs` | 0（主题名可 skip） | 已过 |
| `turn_status` 字段层 | 0 | 已过 |

以最新 `remaining-en.csv` 为准；每关结束重扫覆盖基线。

---

## 8. 文件与命令索引

| 路径 | 用途 |
|------|------|
| `skills/grok-ui-zh/SKILL.md` | 代理执行契约 |
| `skills/grok-ui-zh/references/PLAN.md` | **本方案（完整）** |
| `skills/grok-ui-zh/references/GATES.md` | 关卡勾选板 |
| `skills/grok-ui-zh/references/CHANGELOG.md` | 每轮 diff 摘要 |
| `skills/grok-ui-zh/scripts/inventory-ui.ps1` | 清单主工具 |
| `skills/grok-ui-zh/scripts/scan-ui-en.ps1` | 旧粗扫（不作验收） |
| `workspace/HANDOFF-grok-ui-zh.md` | 跨会话交接 |
| `workspace/PLAN-grok-ui-zh.md` | 工作区入口（指向本文件） |
| `workspace/ui-zh-demo/remaining-en.csv` | 剩余英文行级清单 |
| `workspace/ui-zh-demo/inventory-v2.json` | 机器可读报告 |
| `workspace/ui-zh-demo/gates.json` | 关卡状态机 |

---

## 9. 验收定义（整包完成）

- [ ] `inventory-ui.ps1`：P0 remaining = 0  
- [ ] P1 remaining = 0 或 skip 均有理由  
- [ ] 高频 Action 有中文 `long_help`（快捷键 Enter 详情不再空/英）  
- [ ] 演示页与 tip 一致；exe SHA 写入 HANDOFF  
- [ ] 用户日常路径目视无大块英文 chrome  

---

## 10. 下一动作（当前）

**立即执行：G1 — P0 chrome 整表面清零**  
（`agent_view/render` + `dashboard/{render,peek,row}`）  
完成后 inventory 验收 → 演示 → 等确认 → 再 G2 long_help。
