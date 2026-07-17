# Export slash command descriptions to ui-zh-demo/slash-data.js
param(
  [string]$PagerSrc = "D:\grok-cli\workspace\grok-build\crates\codegen\xai-grok-pager\src\slash\commands",
  [string]$OutJs = "D:\grok-cli\workspace\ui-zh-demo\slash-data.js"
)
$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false
$rows = New-Object System.Collections.Generic.List[object]
Get-ChildItem $PagerSrc -Filter *.rs | ForEach-Object {
  $lines = [IO.File]::ReadAllLines($_.FullName, $utf8)
  $name = $null; $desc = $null
  for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'fn name\(&self\) -> &str') {
      for ($j = $i; $j -lt [Math]::Min($i + 4, $lines.Length); $j++) {
        if ($lines[$j] -match '"([^"]+)"') { $name = $Matches[1]; break }
      }
    }
    if ($lines[$i] -match 'fn description\(&self\) -> &str') {
      for ($j = $i; $j -lt [Math]::Min($i + 6, $lines.Length); $j++) {
        if ($lines[$j] -match '"([^"]+)"') { $desc = $Matches[1]; break }
      }
    }
  }
  if ($name -and $desc) { [void]$rows.Add([pscustomobject]@{ name = $name; desc = $desc }) }
}
$rows = $rows | Sort-Object name
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("window.SLASH_CMDS = [")
foreach ($r in $rows) {
  $n = $r.name.Replace("\", "\\").Replace("'", "\'")
  $d = $r.desc.Replace("\", "\\").Replace("'", "\'")
  [void]$sb.AppendLine("  { name: '$n', desc: '$d' },")
}
[void]$sb.AppendLine("];")
$dir = Split-Path $OutJs -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
[IO.File]::WriteAllText($OutJs, $sb.ToString(), $utf8)
Write-Host "wrote $($rows.Count) commands -> $OutJs"
