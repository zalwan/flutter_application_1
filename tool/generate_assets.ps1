# Generator aset gambar lokal untuk aplikasi Rizal Docs.
#
# Semua gambar dibuat sendiri secara lokal memakai System.Drawing sehingga
# tidak ada aset yang diambil dari internet (sesuai ketentuan Soal 1).
#
# Cara pakai (Windows PowerShell):
#   powershell -ExecutionPolicy Bypass -File tool/generate_assets.ps1
#
# Output:
#   assets/images/profile/profile_rizal.png
#   assets/images/brand/logo_rizal_docs.png
#   assets/images/covers/cover_01.png ... cover_06.png

param(
    [string]$Root = (Join-Path $PSScriptRoot '..')
)

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$profileDir = Join-Path $Root 'assets/images/profile'
$brandDir = Join-Path $Root 'assets/images/brand'
$coverDir = Join-Path $Root 'assets/images/covers'
New-Item -ItemType Directory -Force -Path $profileDir, $brandDir, $coverDir | Out-Null

$fontFamily = 'Segoe UI'

function New-RoundedPath {
    param(
        [System.Drawing.RectangleF]$Rect,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $path.AddArc($Rect.X, $Rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($Rect.X, $Rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Get-Color {
    param([string]$Hex)
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function Get-ColorAlpha {
    param(
        [string]$Hex,
        [int]$Alpha
    )
    $color = Get-Color $Hex
    return [System.Drawing.Color]::FromArgb($Alpha, $color.R, $color.G, $color.B)
}

function New-Canvas {
    param([int]$Width, [int]$Height)

    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Add-Gradient {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$Width,
        [int]$Height,
        [string]$From,
        [string]$To
    )

    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        (Get-Color $From),
        (Get-Color $To),
        90.0
    )
    $Graphics.FillRectangle($brush, $rect)
    $brush.Dispose()
}

function Add-Text {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [string]$FontName,
        [float]$Size,
        [string]$ColorHex,
        [float]$X,
        [float]$Y,
        [float]$MaxWidth = 0,
        [string]$Align = 'near'
    )

    $font = New-Object System.Drawing.Font($FontName, $Size, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush((Get-Color $ColorHex))
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]$Align
    if ($MaxWidth -gt 0) {
        $rect = New-Object System.Drawing.RectangleF($X, $Y, $MaxWidth, 4000)
        $Graphics.DrawString($Text, $font, $brush, $rect, $format)
    }
    else {
        $Graphics.DrawString($Text, $font, $brush, $X, $Y, $format)
    }
    $format.Dispose()
    $brush.Dispose()
    $font.Dispose()
}

function Get-WrappedText {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [float]$MaxWidth
    )

    $words = $Text -split '\s+'
    $lines = New-Object System.Collections.ArrayList
    $current = ''

    foreach ($word in $words) {
        $candidate = if ($current.Length -eq 0) { $word } else { "$current $word" }
        $size = $Graphics.MeasureString($candidate, $Font)
        if ($size.Width -gt $MaxWidth -and $current.Length -gt 0) {
            [void]$lines.Add($current)
            $current = $word
        }
        else {
            $current = $candidate
        }
    }
    if ($current.Length -gt 0) { [void]$lines.Add($current) }
    return $lines
}

# ---------------------------------------------------------------- logo aplikasi
function New-Logo {
    $size = 512
    $canvas = New-Canvas -Width $size -Height $size
    $g = $canvas.Graphics
    $bmp = $canvas.Bitmap

    $g.Clear([System.Drawing.Color]::Transparent)

    # Kartu dasar dengan sudut membulat.
    $cardRect = New-Object System.Drawing.RectangleF(0, 0, 512, 512)
    $cardPath = New-RoundedPath -Rect $cardRect -Radius 112
    $baseBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0, 0, 512, 512)),
        (Get-Color '#1E3A8A'),
        (Get-Color '#0F172A'),
        90.0
    )
    $g.FillPath($baseBrush, $cardPath)
    $baseBrush.Dispose()

    # Lingkaran aksen.
    $glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(38, 245, 158, 11))
    $g.FillEllipse($glowBrush, 250, -90, 360, 360)
    $glowBrush.Dispose()

    # Buku terbuka.
    $leftPage = New-Object System.Drawing.RectangleF(96, 148, 158, 216)
    $rightPage = New-Object System.Drawing.RectangleF(258, 148, 158, 216)
    $pageBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillPath($pageBrush, (New-RoundedPath -Rect $leftPage -Radius 18))
    $g.FillPath($pageBrush, (New-RoundedPath -Rect $rightPage -Radius 18))

    # Garis teks pada halaman.
    $lineBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 30, 58, 138))
    foreach ($offset in @(190, 224, 258, 292)) {
        $g.FillRectangle($lineBrush, 120, $offset, 110, 10)
        $g.FillRectangle($lineBrush, 282, $offset, 110, 10)
    }
    $lineBrush.Dispose()
    $pageBrush.Dispose()

    # Pemisah buku (aksen amber).
    $spineBrush = New-Object System.Drawing.SolidBrush((Get-Color '#F59E0B'))
    $g.FillRectangle($spineBrush, 250, 140, 12, 232)
    $spineBrush.Dispose()

    # Pembatas buku.
    $markerPoints = @(
        (New-Object System.Drawing.PointF(330, 148)),
        (New-Object System.Drawing.PointF(378, 148)),
        (New-Object System.Drawing.PointF(378, 236)),
        (New-Object System.Drawing.PointF(354, 210)),
        (New-Object System.Drawing.PointF(330, 236))
    )
    $markerBrush = New-Object System.Drawing.SolidBrush((Get-Color '#F59E0B'))
    $g.FillPolygon($markerBrush, $markerPoints)
    $markerBrush.Dispose()

    $bmp.Save((Join-Path $brandDir 'logo_rizal_docs.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# ------------------------------------------------------------------ foto profil
function New-ProfilePhoto {
    $size = 640
    $canvas = New-Canvas -Width $size -Height $size
    $g = $canvas.Graphics
    $bmp = $canvas.Bitmap

    Add-Gradient -Graphics $g -Width $size -Height $size -From '#1E3A8A' -To '#0F172A'

    $glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, 245, 158, 11))
    $g.FillEllipse($glow, -120, -140, 520, 520)
    $g.FillEllipse($glow, 330, 380, 420, 420)
    $glow.Dispose()

    # Foto profil berbentuk lingkaran.
    $ringBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 255, 255, 255))
    $g.FillEllipse($ringBrush, 60, 60, 520, 520)
    $ringBrush.Dispose()

    $faceBrush = New-Object System.Drawing.SolidBrush((Get-Color '#E2E8F0'))
    $g.FillEllipse($faceBrush, 92, 92, 456, 456)
    $faceBrush.Dispose()

    # Ilustrasi bahu dan kepala.
    $bodyBrush = New-Object System.Drawing.SolidBrush((Get-Color '#1E3A8A'))
    $bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bodyPath.AddEllipse(142, 330, 356, 280)
    $g.FillPath($bodyBrush, $bodyPath)
    $bodyPath.Dispose()

    $headBrush = New-Object System.Drawing.SolidBrush((Get-Color '#1E3A8A'))
    $g.FillEllipse($headBrush, 232, 168, 176, 176)
    $headBrush.Dispose()

    # Kerah kemeja.
    $collarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 248, 250, 252))
    $collarPoints = @(
        (New-Object System.Drawing.PointF(282, 360)),
        (New-Object System.Drawing.PointF(320, 430)),
        (New-Object System.Drawing.PointF(358, 360))
    )
    $g.FillPolygon($collarBrush, $collarPoints)
    $collarBrush.Dispose()

    # Badge buku (menandakan tema repositori dokumen).
    $badgeBrush = New-Object System.Drawing.SolidBrush((Get-Color '#F59E0B'))
    $g.FillEllipse($badgeBrush, 424, 424, 152, 152)
    $badgeBrush.Dispose()

    $badgeInner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $g.FillRectangle($badgeInner, 462, 472, 76, 14)
    $g.FillRectangle($badgeInner, 462, 500, 76, 14)
    $g.FillRectangle($badgeInner, 462, 528, 52, 14)
    $badgeInner.Dispose()

    $bmp.Save((Join-Path $profileDir 'profile_rizal.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# ---------------------------------------------------------------- cover dokumen
function New-Cover {
    param(
        [string]$FileName,
        [string]$Title,
        [string]$Author,
        [string]$Category,
        [string]$TopColor,
        [string]$BottomColor,
        [string]$AccentColor
    )

    $w = 720
    $h = 960
    $canvas = New-Canvas -Width $w -Height $h
    $g = $canvas.Graphics
    $bmp = $canvas.Bitmap

    Add-Gradient -Graphics $g -Width $w -Height $h -From $TopColor -To $BottomColor

    # Ornamen lingkaran transparan.
    $ornament = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(26, 255, 255, 255))
    $g.FillEllipse($ornament, 430, -160, 520, 520)
    $g.FillEllipse($ornament, -190, 640, 460, 460)
    $ornament.Dispose()

    # Aksen garis vertikal di kiri.
    $accentBrush = New-Object System.Drawing.SolidBrush((Get-Color $AccentColor))
    $g.FillRectangle($accentBrush, 80, 120, 8, 250)
    $accentBrush.Dispose()

    # Label kategori.
    $chipRect = New-Object System.Drawing.RectangleF(80, 120, 0, 52)
    $chipFont = New-Object System.Drawing.Font($fontFamily, 24, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $chipText = $Category.ToUpperInvariant()
    $chipSize = $g.MeasureString($chipText, $chipFont)
    $chipRect.Width = $chipSize.Width + 44
    $chipBrush = New-Object System.Drawing.SolidBrush((Get-ColorAlpha -Hex $AccentColor -Alpha 235))
    $g.FillPath($chipBrush, (New-RoundedPath -Rect $chipRect -Radius 26))
    $chipBrush.Dispose()
    $chipTextBrush = New-Object System.Drawing.SolidBrush((Get-Color '#0F172A'))
    $g.DrawString($chipText, $chipFont, $chipTextBrush, 102, 131)
    $chipTextBrush.Dispose()
    $chipFont.Dispose()

    # Judul dokumen.
    $titleFont = New-Object System.Drawing.Font($fontFamily, 62, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $lines = Get-WrappedText -Graphics $g -Text $Title -Font $titleFont -MaxWidth 520
    $lineY = 300.0
    foreach ($line in $lines) {
        $g.DrawString($line, $titleFont, $titleBrush, 76, $lineY)
        $lineY += 78
    }
    $titleBrush.Dispose()
    $titleFont.Dispose()

    # Garis pemisah.
    $dividerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 3)
    $g.DrawLine($dividerPen, 78, 760, 300, 760)
    $dividerPen.Dispose()

    # Penulis.
    Add-Text -Graphics $g -Text 'OLEH' -FontName $fontFamily -Size 22 -ColorHex '#FFFFFF' -X 78 -Y 790
    Add-Text -Graphics $g -Text $Author -FontName $fontFamily -Size 32 -ColorHex '#FFFFFF' -X 78 -Y 820

    # Branding kecil.
    Add-Text -Graphics $g -Text 'RIZAL DOCS LIBRARY' -FontName $fontFamily -Size 20 -ColorHex '#FFFFFF' -X 78 -Y 892

    $bmp.Save((Join-Path $coverDir $FileName), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

New-Logo
New-ProfilePhoto

$covers = @(
    @{ File = 'cover_01.png'; Title = 'Dasar-Dasar Pemrograman Mobile'; Author = 'Samso Supriyatna'; Category = 'Teknologi'; Top = '#1E3A8A'; Bottom = '#0F172A'; Accent = '#F59E0B' },
    @{ File = 'cover_02.png'; Title = 'Metodologi Penelitian Sistem Informasi'; Author = 'Meta Susanti'; Category = 'Akademik'; Top = '#0F766E'; Bottom = '#042F2E'; Accent = '#FDE68A' },
    @{ File = 'cover_03.png'; Title = 'Basis Data Relasional'; Author = 'Gusmayeni'; Category = 'Teknologi'; Top = '#7C2D12'; Bottom = '#1C1917'; Accent = '#FDBA74' },
    @{ File = 'cover_04.png'; Title = 'Manajemen Proyek Perangkat Lunak'; Author = 'Rizal Suryawan'; Category = 'Manajemen'; Top = '#4C1D95'; Bottom = '#1E1B4B'; Accent = '#C4B5FD' },
    @{ File = 'cover_05.png'; Title = 'Kecerdasan Buatan Terapan'; Author = 'Ade Haerudin'; Category = 'Sains'; Top = '#0369A1'; Bottom = '#082F49'; Accent = '#7DD3FC' },
    @{ File = 'cover_06.png'; Title = 'Bisnis Digital dan Kewirausahaan'; Author = 'Tim Dosen UNPAM'; Category = 'Bisnis'; Top = '#9D174D'; Bottom = '#4C0519'; Accent = '#FBCFE8' }
)

foreach ($cover in $covers) {
    New-Cover -FileName $cover.File -Title $cover.Title -Author $cover.Author -Category $cover.Category -TopColor $cover.Top -BottomColor $cover.Bottom -AccentColor $cover.Accent
}

Write-Host 'Aset berhasil dibuat:'
Get-ChildItem -Recurse (Join-Path $Root 'assets/images') -File | ForEach-Object {
    Write-Host (' - ' + $_.FullName.Replace((Resolve-Path $Root).Path + '\', ''))
}
