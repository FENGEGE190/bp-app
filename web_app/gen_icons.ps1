Add-Type -AssemblyName System.Drawing

$sizes = @(192, 512)
$base = "C:\Users\HAN YU\blood_pressure_app\web_app\icons"

foreach ($sz in $sizes) {
  $bmp = New-Object System.Drawing.Bitmap($sz, $sz)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = "HighQuality"

  $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 25, 118, 210))
  $g.FillEllipse($brush, 0, 0, $sz-1, $sz-1)

  $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  $cx = $sz / 2.0
  $cy = $sz / 2.0
  $r = $sz * 0.22

  $g.FillEllipse($white, [int]($cx - $r*1.1), [int]($cy - $r*0.8), [int]($r*1.5), [int]($r*1.5))
  $g.FillEllipse($white, [int]($cx - $r*0.4), [int]($cy - $r*0.8), [int]($r*1.5), [int]($r*1.5))

  $pt1 = New-Object System.Drawing.Point([int]($cx - $r*1.3), [int]($cy - $r*0.1))
  $pt2 = New-Object System.Drawing.Point([int]($cx + $r*1.3), [int]($cy - $r*0.1))
  $pt3 = New-Object System.Drawing.Point([int]$cx, [int]($cy + $r*1.2))
  $pts = @($pt1, $pt2, $pt3)
  $g.FillPolygon($white, $pts)

  $white.Dispose()
  $brush.Dispose()
  $g.Dispose()
  $bmp.Save("$base\icon-$sz.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Output "Generated icon-$sz.png"
}
Write-Output "Done!"
