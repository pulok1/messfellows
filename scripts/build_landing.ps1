# Builds the Flutter web app into landing/app so the landing page can serve it at /app/.
# Run from anywhere; requires Flutter on PATH.
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    flutter build web --release --base-href /app/ --output landing/app
} finally {
    Pop-Location
}
