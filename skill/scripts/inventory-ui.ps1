# Inventory-first UI string audit for Grok Build TUI (xai-grok-pager).
# Emits machine-readable remaining English surfaces — not noisy "Enish" counts.
#
# Usage:
#   pwsh scripts/inventory-ui.ps1
#   pwsh scripts/inventory-ui.ps1 -OutJson D:\grok-cli\workspace\ui-zh-demo\inventory-v2.json
#
# Exit code 1 if any P0/P1 remaining English rows (gate for "pass complete").
param(
  [string]$PagerSrc = "D:\grok-cli\workspace\grok-build\crates\codegen\xai-grok-pager\src",
  [string]$OutJson = "D:\grok-cli\workspace\ui-zh-demo\inventory-v2.json",
  [string]$OutCsv = "D:\grok-cli\workspace\ui-zh-demo\remaining-en.csv",
  [switch]$FailOnRemaining
)

$ErrorActionPreference = "Stop"

# Surfaces users actually see, ordered by pass priority.
$Surfaces = @(
  # P0 — every session, always on screen
  @{ Priority = "P0"; Rel = "views/turn_status.rs"; Kind = "status" }
  @{ Priority = "P0"; Rel = "scrollback/blocks/session_event.rs"; Kind = "status" }
  @{ Priority = "P0"; Rel = "scrollback/blocks/thinking.rs"; Kind = "status" }
  @{ Priority = "P0"; Rel = "scrollback/blocks/tool/hook.rs"; Kind = "status" }
  @{ Priority = "P0"; Rel = "actions/defaults.rs"; Kind = "actions" }
  @{ Priority = "P0"; Rel = "views/shortcuts_help.rs"; Kind = "shortcuts" }
  @{ Priority = "P0"; Rel = "app/agent_view/render.rs"; Kind = "chrome" }
  @{ Priority = "P0"; Rel = "views/dashboard/render.rs"; Kind = "chrome" }
  @{ Priority = "P0"; Rel = "views/dashboard/peek.rs"; Kind = "chrome" }
  @{ Priority = "P0"; Rel = "views/dashboard/row.rs"; Kind = "chrome" }
  @{ Priority = "P0"; Rel = "slash/commands"; Kind = "slash" }
  # P1 — common flows
  @{ Priority = "P1"; Rel = "settings/defs.rs"; Kind = "settings" }
  @{ Priority = "P1"; Rel = "views/welcome/mod.rs"; Kind = "welcome" }
  @{ Priority = "P1"; Rel = "views/permission_view.rs"; Kind = "permission" }
  @{ Priority = "P1"; Rel = "app/app_view.rs"; Kind = "chrome" }
  @{ Priority = "P1"; Rel = "notifications/title.rs"; Kind = "chrome" }
  @{ Priority = "P1"; Rel = "app/dispatch/session/lifecycle.rs"; Kind = "dialog" }
  @{ Priority = "P1"; Rel = "app/dispatch/session/fork.rs"; Kind = "dialog" }
  @{ Priority = "P1"; Rel = "memory_cmd.rs"; Kind = "dialog" }
  # P2 — less frequent / long form
  @{ Priority = "P2"; Rel = "scrollback/blocks/context_info.rs"; Kind = "panel" }
)

# Field patterns that are almost always user-visible.
$FieldRe = [regex]'(?x)
  \b(?<field>label|description|display|long_help|text|title|placeholder|hint|
     empty_message|footer|header|message|prompt|button|caption)\b
  \s*[:=]\s*
  (?:Some\s*\(\s*)?
  "(?<str>(?:\\.|[^"\\])*)"
'

# format! / write! / Span text that looks like UI copy (multi-word English).
$FormatRe = [regex]'(?x)
  (?:format!|write!|writeln!|Span::styled|Line::from|Text::from|Cow::Borrowed)
  \s*\(\s*
  "(?<str>(?:\\.|[^"\\])*)"
'

# Literal assigned to UI-ish idents on same line.
$AssignRe = [regex]'(?x)
  \b(?<field>status|banner|subtitle|help_text|empty_label|section_title|
     mode_label|flag_text|chip_label)\b
  \s*=\s*
  "(?<str>(?:\\.|[^"\\])*)"
'

function Test-IsChinese([string]$s) {
  return $s -match '[\u4e00-\u9fff]'
}

function Test-IsWireId([string]$s) {
  # config keys, action tokens, single identifiers
  if ($s -match '^[a-z0-9][a-z0-9_\-./:]*$') { return $true }
  if ($s -match '^[A-Z][A-Za-z0-9_]+$') { return $true } # enum-like
  return $false
}

function Test-IsThemeName([string]$s) {
  return $s -match '^(Grok Night|Grok Day|Tokyo Night|Rose Pine|Oscura|Dracula|Catppuccin)'
}

function Test-IsPlaceholderHeavy([string]$s) {
  # Formats that are only placeholders + punctuation/units (no real English copy).
  # e.g. "{body} ({secs:.1}s)", " {time_str}", "{} {work}", " {icon}"
  $t = $s -replace '\{[^}]+\}', ''
  $t = $t -replace '[\d\s.,:;()\[\]{}\\\/%+\-*_·…\u2026\u2014\u00b7#@!~`''"]+', ''
  # bare unit tokens left after stripping numbers/placeholders
  $t = $t -replace '(?i)^(ms|s|m|h|k|tok|tokens)?$', ''
  if ([string]::IsNullOrWhiteSpace($t)) { return $true }
  if ($t -notmatch '[A-Za-z]{3,}') { return $true }
  return $false
}

function Test-IsNoise([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $true }
  if ($s.Length -lt 2) { return $true }
  if (Test-IsWireId $s) { return $true }
  if (Test-IsThemeName $s) { return $true }
  if ($s -match '^(https?://|\\\\|src/|crates/|file://)') { return $true }
  if ($s -match '::|->|\{[a-z_]+\}\s*\{') { return $true }
  # test / fixture technical messages (not user-facing UI)
  if ($s -match '(?i)must fail|must suppress|must be|must not|fixture must|\bguard\b|modal clear returned|channel-backed|on char boundary|cannot carry|pipeline channel') { return $true }
  if ($s -match 'assert|panic|debug|FIXME|TODO|unimplemented') { return $true }
  # test fixture labels
  if ($s -match '(?i)^CLIPBOARD(\s|$)') { return $true }
  # pure placeholders / icon-only / unit-only formats
  if (Test-IsPlaceholderHeavy $s) { return $true }
  # icon-only / whitespace-padded glyph literals (no English word)
  if ($s -match '^\s*\{[a-zA-Z_][a-zA-Z0-9_]*\}\s*$') { return $true }
  # key chord displays are OK to keep Latin: Ctrl+X, Alt+Enter
  if ($s -match '^(Ctrl|Alt|Shift|Cmd|Meta|Enter|Esc|Tab|Space|F\d)([+/\- ]|$)') { return $true }
  # Slash command tokens / usage scaffolds must stay English: "/compact {}", "/loop {args}"
  if ($s -match '^/[a-z][a-z0-9_\-]*(?:\s|$)') { return $true }
  # CLI flag names: "--effort/--reasoning-effort: {}"
  if ($s -match '^--[a-z]') { return $true }
  # Diagnostic env field keys (tooling brands), not prose
  if ($s -match '(?i)\b(xtversion|byobu|tmux|vte|xterm\.js)\b' -and $s -notmatch '[\u4e00-\u9fff]') {
    if ($s -match '^\s*[a-z0-9_.]+\s*\{\}' -or $s -match '^\s*[a-z0-9_.]+\s+\{\}') { return $true }
  }
  if ($s -match '^[jkhlHL]$|^j/k$|^\u2191|\u2193') { return $true }
  return $false
}

function Test-LooksEnglishUi([string]$s) {
  if (Test-IsChinese $s) { return $false }
  if (Test-IsNoise $s) { return $false }
  if ($s -notmatch '[A-Za-z]{3,}') { return $false }
  # multi-word, or ends with colon/ellipsis (status prefixes), or sentence
  if ($s -match '\s') { return $true }
  if ($s -match '[:…]$|\.\.\.$|[.!?]$') { return $true }
  if ($s -match '^(Yes|No|Cancel|Close|Open|Save|Delete|Rename|Resume|Import|Upgrade|Waiting|Loading|Thinking|Starting|Error|Failed|Success|Allow|Reject|Always|Never)\b') { return $true }
  return $false
}

function Strip-Escapes([string]$s) {
  return ($s -replace '\\n', ' ' -replace '\\t', ' ' -replace '\\"', '"' -replace '\\\\', '\')
}

function Get-Files([string]$rel) {
  $p = Join-Path $PagerSrc ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path $p)) { return @() }
  if (Test-Path $p -PathType Container) {
    return @(Get-ChildItem $p -Filter *.rs -Recurse -File | Where-Object { $_.Name -notmatch 'test' })
  }
  return @(Get-Item $p)
}

function Skip-TestRegions([string[]]$lines) {
  # Yield (lineNo 1-based, text) excluding:
  #   - mod tests { ... } blocks
  #   - #[cfg(...test...)] mod <any> { ... } blocks
  #   - #[cfg(...test...)] fn ... { ... } blocks (best-effort brace depth)
  $inTest = $false
  $depth = 0
  $pendingCfgTest = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if (-not $inTest) {
      # mod tests — allow pub / pub(crate) visibility; cfg optional same-line
      if ($line -match '^\s*(#\[cfg\([^\]]*test[^\]]*\)\]\s*)?(pub(\s*\([^)]*\))?\s+)?mod\s+tests\b') {
        $inTest = $true
        $depth = 0
        $pendingCfgTest = $false
      }
      # same-line: #[cfg(test)] mod foo / #[cfg(test)] fn foo
      elseif ($line -match '^\s*#\[cfg\([^\]]*test[^\]]*\)\].*\b(mod|fn)\s+') {
        $inTest = $true
        $depth = 0
        $pendingCfgTest = $false
      }
      # bare #[cfg(...test...)] — next non-attr/non-blank line may open test mod/fn
      elseif ($line -match '^\s*#\[cfg\([^\]]*test[^\]]*\)\]') {
        $pendingCfgTest = $true
        continue
      }
      elseif ($pendingCfgTest) {
        if ($line -match '^\s*$') { continue }
        if ($line -match '^\s*#\[') { continue } # stacked attributes
        # any module or function under cfg(test) is test-only surface
        if ($line -match '^\s*(pub(\s*\([^)]*\))?\s+)?(async\s+)?(mod|fn)\s+') {
          $inTest = $true
          $depth = 0
          $pendingCfgTest = $false
        } else {
          # not a mod/fn — abandon (e.g. cfg(test) on a const/use/type)
          $pendingCfgTest = $false
        }
      }
    }

    if ($inTest) {
      $depth += ([regex]::Matches($line, '\{')).Count
      $depth -= ([regex]::Matches($line, '\}')).Count
      if ($depth -le 0 -and $line -match '\}') { $inTest = $false }
      continue
    }
    if ($line -match '^\s*//') { continue }
    if ($line -match '\b(assert|assert_eq|assert_ne|panic!|unreachable!|debug_assert)') { continue }
    [pscustomobject]@{ N = $i + 1; T = $line }
  }
}

$rows = [System.Collections.Generic.List[object]]::new()
$stats = [System.Collections.Generic.List[object]]::new()

foreach ($surf in $Surfaces) {
  $files = Get-Files $surf.Rel
  $zh = 0; $en = 0; $skip = 0
  foreach ($f in $files) {
    $raw = [IO.File]::ReadAllText($f.FullName)
    $lines = $raw -split "`r?`n", -1
    $kept = @(Skip-TestRegions $lines)
    $relFile = $f.FullName.Substring($PagerSrc.Length).TrimStart('\', '/') -replace '\\', '/'

    foreach ($item in $kept) {
      $line = $item.T
      $hits = @()
      foreach ($m in $FieldRe.Matches($line)) {
        $hits += [pscustomobject]@{ Field = $m.Groups['field'].Value; Str = (Strip-Escapes $m.Groups['str'].Value); How = 'field' }
      }
      foreach ($m in $AssignRe.Matches($line)) {
        $hits += [pscustomobject]@{ Field = $m.Groups['field'].Value; Str = (Strip-Escapes $m.Groups['str'].Value); How = 'assign' }
      }
      foreach ($m in $FormatRe.Matches($line)) {
        $hits += [pscustomobject]@{ Field = 'format'; Str = (Strip-Escapes $m.Groups['str'].Value); How = 'format' }
      }
      # bare UI-ish literals on Span/Paragraph construction lines
      if ($line -match 'Span::|Paragraph::|Line::|HintItem|PromptFlag|Modal|title:|footer:') {
        foreach ($m in [regex]::Matches($line, '"(?<str>(?:\\.|[^"\\])*)"')) {
          $s = Strip-Escapes $m.Groups['str'].Value
          if ($s.Length -ge 2) {
            $hits += [pscustomobject]@{ Field = 'literal'; Str = $s; How = 'literal' }
          }
        }
      }

      foreach ($h in $hits) {
        if (Test-IsChinese $h.Str) { $zh++; continue }
        if (-not (Test-LooksEnglishUi $h.Str)) { $skip++; continue }
        $en++
        $rows.Add([pscustomobject]@{
          Priority = $surf.Priority
          Surface  = $surf.Rel
          Kind     = $surf.Kind
          File     = $relFile
          Line     = $item.N
          Field    = $h.Field
          How      = $h.How
          Text     = $h.Str
          Status   = "en"
        }) | Out-Null
      }
    }
  }

  $stats.Add([pscustomobject]@{
    Priority = $surf.Priority
    Surface  = $surf.Rel
    Kind     = $surf.Kind
    ZhHits   = $zh
    EnRemaining = $en
    NoiseSkipped = $skip
    Files    = $files.Count
  }) | Out-Null
}

# Dedupe identical file:line:text
$dedup = $rows | Sort-Object File, Line, Text -Unique

$report = [ordered]@{
  generated_at = (Get-Date).ToString("o")
  pager_src    = $PagerSrc
  summary      = [ordered]@{
    surfaces       = $stats.Count
    remaining_en   = @($dedup).Count
    p0_remaining   = @($dedup | Where-Object Priority -eq 'P0').Count
    p1_remaining   = @($dedup | Where-Object Priority -eq 'P1').Count
    p2_remaining   = @($dedup | Where-Object Priority -eq 'P2').Count
  }
  by_surface   = @($stats | Sort-Object Priority, @{e={$_.EnRemaining}; desc=$true})
  remaining    = @($dedup | Sort-Object Priority, File, Line)
}

$dir = Split-Path $OutJson -Parent
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$json = $report | ConvertTo-Json -Depth 6
# Windows PowerShell 5.x has no utf8NoBOM; write UTF-8 without BOM explicitly.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($OutJson, $json, $utf8NoBom)

$dedup | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "=== UI inventory summary ===" -ForegroundColor Cyan
Write-Host ("Remaining EN: {0}  (P0={1} P1={2} P2={3})" -f `
  $report.summary.remaining_en, $report.summary.p0_remaining, `
  $report.summary.p1_remaining, $report.summary.p2_remaining)
Write-Host ""
$stats | Sort-Object Priority, @{e={$_.EnRemaining}; desc=$true} | Format-Table -AutoSize `
  Priority, @{n='En';e={$_.EnRemaining}}, @{n='Zh';e={$_.ZhHits}}, Surface
Write-Host "JSON: $OutJson"
Write-Host "CSV:  $OutCsv"

if ($FailOnRemaining -and $report.summary.p0_remaining -gt 0) {
  Write-Error "P0 still has $($report.summary.p0_remaining) English UI strings — pass incomplete."
  exit 1
}
if ($FailOnRemaining -and $report.summary.p1_remaining -gt 0) {
  Write-Error "P1 still has $($report.summary.p1_remaining) English UI strings — pass incomplete."
  exit 1
}
exit 0
