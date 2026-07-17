# 汉化关卡勾选板

> 规则见 `PLAN.md`。每关：inventory → 改 → inventory En=0 → 演示 → 确认 → push/CI → 写 SHA。

| 关 | 表面 | 状态 | tip/SHA | run-id | 备注 |
|----|------|------|---------|--------|------|
| G0 | 状态行/思考/回合 | **源码已清** | 工作区 | — | hook/thinking/session_event |
| G1 | 聊天+仪表盘 chrome | **源码已清** | 工作区 | — | render/dashboard + HintItem 全中文 |
| G2 | 快捷键 long_help | **源码已清** | 工作区 | — | defaults 55 条中文 long_help |
| G3 | slash 去噪+真 UI 尾 | **源码已清** | 工作区 | — | /cmd 字保留英文 |
| G4 | welcome 全流程 | **源码已清** | 工作区 | — | 登录/恢复/更新日志 |
| G5 | 权限弹窗 | **源码已清** | 工作区 | — | permission_view |
| G6 | app_view / 会话对话框 | **源码已清** | 工作区 | — | lifecycle/fork |
| G7 | P2 扫尾+缺字 | **源码已清** | 工作区 | — | context `\|` 分隔防缺字 |

## 验收（2026-07-17）

```
inventory-ui.ps1 → Remaining EN: 0  (P0=0 P1=0 P2=0)
```

## 发布

| 项 | 值 |
|----|-----|
| tip | `d897b03` |
| push run | `29549638023`（in_progress） |
| dispatch run | `29549638022` |
| 下一动作 | CI success → 装 exe 写 SHA |

## 状态字

- `待做` / `进行中` / `源码已清` / `演示待确认` / `已发布` / `skip(理由)`
