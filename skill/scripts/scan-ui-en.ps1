# Rough scan of English-ish UI strings remaining in key modules
param(
  [string]$PagerSrc = "D:\grok-cli\workspace\grok-build\crates\codegen\xai-grok-pager\src"
)
$ErrorActionPreference = "Stop"
$mods = @(
  "views/turn_status.rs",
  "scrollback/blocks/session_event.rs",
  "scrollback/blocks/context_info.rs",
  "views/welcome/mod.rs",
  "actions/defaults.rs",
  "settings/defs.rs",
  "views/permission_view.rs",
  "views/shortcuts_help.rs",
  "slash/commands"
)
function Count-ZhEn([string]$path) {
  $files = if (Test-Path $path -PathType Container) {
    Get-ChildItem $path -Filter *.rs -Recurse
  } else { @(Get-Item $path) }
  $zh = 0; $en = 0
  foreach ($f in $files) {
    $t = [IO.File]::ReadAllText($f.FullName)
    $zh += ([regex]::Matches($t, '"[^"]*[\u4e00-\u9fff][^"]*"')).Count
    $en += ([regex]::Matches($t, '"(?:[A-Z][a-z]+(?:\s+[A-Za-z][\w''-]*){1,}|[a-z]{3,20})"')).Count
  }
  [pscustomobject]@{ Module = $path; Zh = $zh; Enish = $en }
}
$mods | ForEach-Object {
  $p = Join-Path $PagerSrc $_
  if (Test-Path $p) { Count-ZhEn $p }
} | Format-Table -AutoSize
