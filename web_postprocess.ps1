# web_postprocess.ps1 — Post-process Flutter web build for itch.io hosting
# Run after: flutter build web --release --no-tree-shake-icons --pwa-strategy none --no-web-resources-cdn
#
# itch.io blocks .json, .ttf, .otf, and even .bin font files with 403 Forbidden.
# This script works around that by:
# - Inlining FontManifest data via a fetch() interceptor
# - Renaming all font files to .bin extension
# - Embedding all font data as base64 in a .js file (itch.io serves .js fine)
# - The fetch interceptor decodes base64 font data at runtime
# - Fixing base href for relative paths

$webDir = "build\web"

# 1. Fix base href (itch.io serves from subdirectory, not root)
Write-Host "  [1/6] Fixing base href..."
$html = Get-Content "$webDir\index.html" -Raw
$html = $html -replace '<base href="/">', '<base href="./">'

# 2. Rename all .ttf and .otf files to .bin (needed for consistent naming in interceptor)
Write-Host "  [2/6] Renaming font files to .bin..."
Get-ChildItem -Path "$webDir\assets" -Recurse -Include "*.ttf","*.otf" | ForEach-Object {
    $newName = $_.Name -replace '\.(ttf|otf)$', '.bin'
    Rename-Item -Path $_.FullName -NewName $newName -Force
    Write-Host "    $($_.Name) -> $newName"
}

# 3. Generate font_data.js — embed all font files as base64
Write-Host "  [3/6] Generating font_data.js (base64 embedded fonts)..."
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
        Write-Host "    $key : $sizeKB KB -> $b64KB KB base64"
    } else {
        Write-Host "    SKIP: $path not found"
    }
}
Set-Content "$webDir\font_data.js" $js -NoNewline
$totalMB = [math]::Round((Get-Item "$webDir\font_data.js").Length / 1MB, 2)
Write-Host "    font_data.js: $totalMB MB"

# 4. Inject font_data.js loader + fetch interceptor for FontManifest + font files
Write-Host "  [4/6] Injecting fetch interceptor (FontManifest + base64 fonts)..."
$interceptor = @'
  <!-- Load embedded font data (itch.io blocks all font file downloads with 403) -->
  <script src="font_data.js"></script>
  <!-- Intercept fetch for FontManifest.json AND font files — serve from embedded base64 -->
  <script>
    var _originalFetch = window.fetch;
    window.fetch = function(url, options) {
      if (typeof url === 'string') {
        // Intercept FontManifest.json — itch.io blocks .json with 403
        if (url.indexOf('FontManifest.json') !== -1) {
          var manifest = [
            {"family":"Roboto","fonts":[{"asset":"assets/fonts/Roboto-Regular.bin","weight":400},{"asset":"assets/fonts/Roboto-Bold.bin","weight":700},{"asset":"assets/fonts/Roboto-Light.bin","weight":300},{"asset":"assets/fonts/Roboto-Medium.bin","weight":500},{"asset":"assets/fonts/Roboto-Thin.bin","weight":100},{"asset":"assets/fonts/Roboto-Black.bin","weight":900}]},
            {"family":"MaterialIcons","fonts":[{"asset":"fonts/MaterialIcons-Regular.bin"}]},
            {"family":"packages/cupertino_icons/CupertinoIcons","fonts":[{"asset":"packages/cupertino_icons/assets/CupertinoIcons.bin"}]}
          ];
          return Promise.resolve(new Response(JSON.stringify(manifest), {
            status: 200,
            headers: {'Content-Type': 'application/json'}
          }));
        }
        // Intercept font file requests — serve from embedded base64 data
        if (window._fd) {
          var fd = window._fd;
          for (var key in fd) {
            if (url.indexOf(key) !== -1) {
              var b64 = fd[key];
              var bin = atob(b64);
              var bytes = new Uint8Array(bin.length);
              for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
              return Promise.resolve(new Response(bytes.buffer, {
                status: 200,
                headers: {'Content-Type': 'font/opentype'}
              }));
            }
          }
        }
      }
      return _originalFetch.apply(this, arguments);
    };
  </script>
  <script src="flutter_bootstrap.js" async></script>
'@
$html = $html -replace '  <script src="flutter_bootstrap.js" async></script>', $interceptor
Set-Content "$webDir\index.html" $html -NoNewline

# 5. Remove serviceWorkerSettings (no SW needed on itch.io)
Write-Host "  [5/6] Removing service worker registration..."
$bootJs = Get-Content "$webDir\flutter_bootstrap.js" -Raw
$bootJs = $bootJs -replace '(?s)_flutter\.loader\.load\(\{.*?\}\);', '_flutter.loader.load();'
Set-Content "$webDir\flutter_bootstrap.js" $bootJs -NoNewline

# 6. Remove service worker file (not needed for itch.io)
Write-Host "  [6/6] Removing service worker..."
$swPath = "$webDir\flutter_service_worker.js"
if (Test-Path $swPath) {
    Remove-Item $swPath -Force
}

Write-Host "  Post-processing complete!"
