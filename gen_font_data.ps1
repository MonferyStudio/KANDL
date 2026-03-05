# Generate font_data.js — embeds font files as base64 in JavaScript
# itch.io blocks all font file downloads (403), regardless of extension
# So we embed them in a .js file which itch.io serves fine

$webDir = "c:\Users\Greem\stockos\build\web"

$fonts = @{
    "fonts/MaterialIcons-Regular" = "$webDir\assets\fonts\MaterialIcons-Regular.bin"
    "assets/fonts/Roboto-Regular" = "$webDir\assets\assets\fonts\Roboto-Regular.bin"
    "assets/fonts/Roboto-Bold" = "$webDir\assets\assets\fonts\Roboto-Bold.bin"
    "assets/fonts/Roboto-Light" = "$webDir\assets\assets\fonts\Roboto-Light.bin"
    "assets/fonts/Roboto-Medium" = "$webDir\assets\assets\fonts\Roboto-Medium.bin"
    "assets/fonts/Roboto-Thin" = "$webDir\assets\assets\fonts\Roboto-Thin.bin"
    "assets/fonts/Roboto-Black" = "$webDir\assets\assets\fonts\Roboto-Black.bin"
    "packages/cupertino_icons/assets/CupertinoIcons" = "$webDir\assets\packages\cupertino_icons\assets\CupertinoIcons.bin"
}

$js = "window._fd={};" + "`n"

foreach ($entry in $fonts.GetEnumerator()) {
    $key = $entry.Key
    $path = $entry.Value
    if (Test-Path $path) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $b64 = [Convert]::ToBase64String($bytes)
        $js += "window._fd[`"$key`"]=`"$b64`";" + "`n"
        $sizeKB = [math]::Round($bytes.Length / 1KB, 1)
        $b64KB = [math]::Round($b64.Length / 1KB, 1)
        Write-Host "  $key : $sizeKB KB -> $b64KB KB base64"
    } else {
        Write-Host "  SKIP: $path not found"
    }
}

Set-Content "$webDir\font_data.js" $js -NoNewline
$totalMB = [math]::Round((Get-Item "$webDir\font_data.js").Length / 1MB, 2)
Write-Host ""
Write-Host "  font_data.js: $totalMB MB"
