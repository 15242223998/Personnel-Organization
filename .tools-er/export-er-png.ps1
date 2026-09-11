﻿# 生成 docs/ER实体图.png
# 读取 .tools-er/er-model.json（由 gen-er.js 生成的解析结果），使用 .NET System.Drawing 离线绘制 ER 实体图。
# 约束：不安装依赖、不联网渲染、不访问数据库；仅用 PowerShell 5.1 + .NET 内置程序集。
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

# ------------------------------ 路径 ------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($ScriptDir)) { $ScriptDir = (Get-Location).Path }
$Root      = Split-Path -Parent $ScriptDir
$ModelFile = Join-Path $ScriptDir 'er-model.json'
$OutDir    = Join-Path $Root 'docs'
$OutFile   = Join-Path $OutDir 'ER实体图.png'

if (-not (Test-Path -LiteralPath $ModelFile)) {
  throw "[export-er] 未找到模型文件: $ModelFile（请先运行 node .tools-er/gen-er.js）"
}

# ------------------------------ 读模型 ------------------------------
# 兼容带 BOM / 不带 BOM 的 UTF-8
$raw = Get-Content -LiteralPath $ModelFile -Raw -Encoding UTF8
$raw = $raw.TrimStart([char[]]@([char]0xFEFF, [char]0x200B))
$model = $raw | ConvertFrom-Json

$tables = @($model.tables)
$rels   = @($model.relations)
$count  = $tables.Count

# ------------------------------ 布局参数 ------------------------------
$Cols    = 5      # 每行表格数
$CellW   = 380    # 单元格宽
$GapX    = 36     # 横向间距
$GapY    = 48     # 纵向间距
$Margin  = 60     # 外边距
$TitleH  = 90     # 标题区高度
$HeadH   = 30     # 表头高度
$RowH    = 17     # 字段行高
$PadY    = 10     # 表格内上下内边距（额外）
$PadX    = 8      # 表格内左右内边距

$rows = [int][Math]::Ceiling($count / [double]$Cols)

# 每张表的高度 = 表头 + 字段数*行高 + 内边距
$heights = @()
for ($i = 0; $i -lt $count; $i++) {
  $heights += ($HeadH + (@($tables[$i].fields).Count * $RowH) + $PadY)
}

# 同一行的行高取该行最大高度，保证对齐（多余空间留白）
$rowHeights = @()
for ($r = 0; $r -lt $rows; $r++) {
  $max = 0
  for ($c = 0; $c -lt $Cols; $c++) {
    $i = $r * $Cols + $c
    if ($i -lt $count -and $heights[$i] -gt $max) { $max = $heights[$i] }
  }
  $rowHeights += $max
}

$canvasW = $Margin * 2 + $Cols * $CellW + ($Cols - 1) * $GapX
$bodyH   = 0
foreach ($h in $rowHeights) { $bodyH += $h }
$bodyH += ($rows - 1) * $GapY
$canvasH = $Margin + $TitleH + $bodyH + $Margin

# ------------------------------ 计算每个表格矩形 ------------------------------
$rects = @{}
$cursorY = $Margin + $TitleH
for ($r = 0; $r -lt $rows; $r++) {
  for ($c = 0; $c -lt $Cols; $c++) {
    $i = $r * $Cols + $c
    if ($i -ge $count) { continue }
    $x = $Margin + $c * ($CellW + $GapX)
    $rects[[string]$tables[$i].name] = [System.Drawing.RectangleF]::new(
      [float]$x, [float]$cursorY, [float]$CellW, [float]$heights[$i])
  }
  $cursorY += $rowHeights[$r] + $GapY
}

# ------------------------------ 字体 ------------------------------
$families = @()
try {
  $families = (New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
} catch { $families = @() }

$FontFamily = 'SimSun'
if ($families -contains 'Microsoft YaHei') { $FontFamily = 'Microsoft YaHei' }

function New-PxFont {
  param([string]$Family, [double]$Size, [System.Drawing.FontStyle]$Style)
  return [System.Drawing.Font]::new($Family, [float]$Size, $Style, [System.Drawing.GraphicsUnit]::Pixel)
}

$fontTitle    = New-PxFont $FontFamily 26 ([System.Drawing.FontStyle]::Bold)
$fontSubtitle = New-PxFont $FontFamily 13 ([System.Drawing.FontStyle]::Regular)
$fontHeader   = New-PxFont $FontFamily 13 ([System.Drawing.FontStyle]::Bold)
$fontField    = New-PxFont $FontFamily 11 ([System.Drawing.FontStyle]::Regular)
$fontPk       = New-PxFont $FontFamily 11 ([System.Drawing.FontStyle]::Bold)
$fontComment  = New-PxFont $FontFamily 10 ([System.Drawing.FontStyle]::Regular)

# ------------------------------ 画笔画刷 ------------------------------
$brushBg        = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$brushBoxFill   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(247, 250, 255))
$brushHeadFill  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(25, 118, 210))
$brushHeadText  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$brushField     = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(51, 51, 51))
$brushPk        = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 71, 161))
$brushComment   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(136, 136, 136))
$brushTitle     = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 71, 161))
$brushSubtitle  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 120, 120))

$penBox     = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(25, 118, 210), [float]1.5)
$penRel     = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(70, 120, 140, 170), [float]1.0)

$sfHead    = [System.Drawing.StringFormat]::new()
$sfHead.Alignment = [System.Drawing.StringAlignment]::Near
$sfHead.LineAlignment = [System.Drawing.StringAlignment]::Center
$sfHead.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap

$sfCenter  = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
$sfCenter.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap

$sfDraw    = [System.Drawing.StringFormat]::new()
$sfDraw.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
$sfMeasure = [System.Drawing.StringFormat]::GenericTypographic

# ------------------------------ 工具函数 ------------------------------
function New-RoundedPath {
  param([System.Drawing.RectangleF]$Rect, [float]$Radius)
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $d = [float]($Radius * 2)
  $path.AddArc($Rect.X, $Rect.Y, $d, $d, 180, 90)
  $path.AddArc(($Rect.Right - $d), $Rect.Y, $d, $d, 270, 90)
  $path.AddArc(($Rect.Right - $d), ($Rect.Bottom - $d), $d, $d, 0, 90)
  $path.AddArc($Rect.X, ($Rect.Bottom - $d), $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Measure-Text {
  param($Graphics, [string]$Text, $Font)
  if ([string]::IsNullOrEmpty($Text)) { return 0.0 }
  return $Graphics.MeasureString($Text, $Font, [int]10000, $sfMeasure).Width
}

# 按最大宽度截断文本，超出部分用省略号
function Get-FittedText {
  param($Graphics, [string]$Text, $Font, [double]$MaxWidth)
  if ([string]::IsNullOrEmpty($Text)) { return '' }
  if ((Measure-Text $Graphics $Text $Font) -le $MaxWidth) { return $Text }
  $ellipsis = [char]0x2026
  for ($n = $Text.Length - 1; $n -gt 0; $n--) {
    $cand = $Text.Substring(0, $n) + $ellipsis
    if ((Measure-Text $Graphics $cand $Font) -le $MaxWidth) { return $cand }
  }
  return [string]$ellipsis
}

# ------------------------------ 开始绘制 ------------------------------
$bmp = [System.Drawing.Bitmap]::new([int]$canvasW, [int]$canvasH)
$bmp.SetResolution(96, 96)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.Clear([System.Drawing.Color]::White)

# ① 先画关系线（最底层）：从源表框中心到目标表框中心
$drawnRels = 0
foreach ($rel in $rels) {
  $fromKey = [string]$rel.from
  $toKey   = [string]$rel.to
  if (-not $rects.ContainsKey($fromKey) -or -not $rects.ContainsKey($toKey)) { continue }
  $a = $rects[$fromKey]
  $b = $rects[$toKey]
  $p1 = [System.Drawing.PointF]::new([float]($a.X + $a.Width / 2), [float]($a.Y + $a.Height / 2))
  $p2 = [System.Drawing.PointF]::new([float]($b.X + $b.Width / 2), [float]($b.Y + $b.Height / 2))
  $midY = [float](($p1.Y + $p2.Y) / 2)
  $c1 = [System.Drawing.PointF]::new([float]$p1.X, $midY)
  $c2 = [System.Drawing.PointF]::new([float]$p2.X, $midY)
  $g.DrawBezier($penRel, $p1, $c1, $c2, $p2)
  $drawnRels++
}

# ② 再画表格方框（盖在关系线之上）
$maxContentW = [double]($CellW - 2 * $PadX)
foreach ($t in $tables) {
  $name = [string]$t.name
  if (-not $rects.ContainsKey($name)) { continue }
  $rect = $rects[$name]

  $path = New-RoundedPath $rect ([float]6)
  $g.FillPath($brushBoxFill, $path)

  # 表头色带（裁剪在圆角路径内）
  $state = $g.Save()
  $g.SetClip($path)
  $g.FillRectangle($brushHeadFill, $rect.X, $rect.Y, $rect.Width, [float]$HeadH)
  $g.Restore($state)

  $g.DrawPath($penBox, $path)
  $path.Dispose()

  # 表头文字：表名（注释）
  $comment = [string]$t.comment
  $headText = $name
  if (-not [string]::IsNullOrEmpty($comment)) { $headText = $name + '（' + $comment + '）' }
  $headText = Get-FittedText $g $headText $fontHeader $maxContentW
  $headRect = [System.Drawing.RectangleF]::new(
    [float]($rect.X + $PadX), [float]$rect.Y, [float]$maxContentW, [float]$HeadH)
  $g.DrawString($headText, $fontHeader, $brushHeadText, $headRect, $sfHead)

  # 字段行
  $fields = @($t.fields)
  $rowTop = [float]($rect.Y + $HeadH + 5)
  for ($k = 0; $k -lt $fields.Count; $k++) {
    $f = $fields[$k]
    $rowY = [float]($rowTop + $k * $RowH)
    $isPk = [bool]$f.pk
    $fName = [string]$f.name
    $fType = [string]$f.type
    $fComment = [string]$f.comment

    $prefix = $fName + '   ' + $fType
    $pf = $fontField
    $pb = $brushField
    if ($isPk) {
      $prefix = 'PK ' + $prefix
      $pf = $fontPk
      $pb = $brushPk
    }

    $prefixW = Measure-Text $g $prefix $pf
    if ($prefixW -gt $maxContentW) {
      $prefix = Get-FittedText $g $prefix $pf $maxContentW
      $prefixW = Measure-Text $g $prefix $pf
    }
    $g.DrawString($prefix, $pf, $pb, [System.Drawing.PointF]::new([float]($rect.X + $PadX), $rowY), $sfDraw)

    if (-not [string]::IsNullOrEmpty($fComment)) {
      $cLeft = [float]($rect.X + $PadX + $prefixW + 4)
      $avail = [double]($maxContentW - $prefixW - 4)
      if ($avail -gt 24) {
        $cText = Get-FittedText $g ('// ' + $fComment) $fontComment $avail
        $g.DrawString($cText, $fontComment, $brushComment, [System.Drawing.PointF]::new($cLeft, ($rowY + 1.5)), $sfDraw)
      }
    }
  }
}

# ③ 顶部标题
$titleText = '辽宁某某大学干部人事系统 ER 实体图（表 {0} · 字段 {1} · 关系 {2}）' -f $model.tableCount, $model.fieldCount, $model.relationCount
$titleRect = [System.Drawing.RectangleF]::new([float]0, [float]20, [float]$canvasW, [float]44)
$g.DrawString($titleText, $fontTitle, $brushTitle, $titleRect, $sfCenter)

$subtitleText = '由 sql/init.sql 自动解析生成，线条为字段名推断的关联关系'
$subtitleRect = [System.Drawing.RectangleF]::new([float]0, [float]66, [float]$canvasW, [float]24)
$g.DrawString($subtitleText, $fontSubtitle, $brushSubtitle, $subtitleRect, $sfCenter)

$g.Dispose()

# ------------------------------ 保存 ------------------------------
if (-not (Test-Path -LiteralPath $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

foreach ($d in @($brushBg, $brushBoxFill, $brushHeadFill, $brushHeadText, $brushField, $brushPk,
                 $brushComment, $brushTitle, $brushSubtitle, $penBox, $penRel,
                 $fontTitle, $fontSubtitle, $fontHeader, $fontField, $fontPk, $fontComment,
                 $sfHead, $sfCenter, $sfDraw)) {
  if ($null -ne $d) { $d.Dispose() }
}

# ------------------------------ 自检 ------------------------------
$check = [System.Drawing.Bitmap]::new($OutFile)
$step = 20
$total = 0
$nonWhite = 0
for ($y = 0; $y -lt $check.Height; $y += $step) {
  for ($x = 0; $x -lt $check.Width; $x += $step) {
    $total++
    $px = $check.GetPixel($x, $y)
    if ($px.R -lt 250 -or $px.G -lt 250 -or $px.B -lt 250) { $nonWhite++ }
  }
}
$check.Dispose()

$ratio = 0.0
if ($total -gt 0) { $ratio = [Math]::Round(100.0 * $nonWhite / $total, 2) }
$sizeKB = [Math]::Round((Get-Item -LiteralPath $OutFile).Length / 1024.0, 1)

Write-Host ('[export-er] 模型文件: ' + $ModelFile)
Write-Host ('[export-er] 输出文件: ' + $OutFile)
Write-Host ('[export-er] 字体: ' + $FontFamily)
Write-Host ('[export-er] 表格数: ' + $count + ' / 关系数: ' + $rels.Count + ' / 绘制关系线: ' + $drawnRels)
Write-Host ('[export-er] 网格: ' + $Cols + ' 列 x ' + $rows + ' 行')
Write-Host ('[export-er] 画布尺寸: ' + $canvasW + ' x ' + $canvasH + ' px')

$verify = [System.Drawing.Bitmap]::new($OutFile)
Write-Host ('[export-er] 读回 PNG 宽高: ' + $verify.Width + ' x ' + $verify.Height + ' px')
$verify.Dispose()
Write-Host ('[export-er] 文件大小: ' + $sizeKB + ' KB')
Write-Host ('[export-er] 非白像素占比(每 ' + $step + 'px 采样, 样本 ' + $total + '): ' + $ratio + ' %')
