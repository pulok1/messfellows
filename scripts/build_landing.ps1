# Builds the Flutter web app into landing/app so the landing page can serve it at /app/.
# Run from anywhere; requires Flutter on PATH.
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    # Bake in cloud sync config when a local supabase.json exists (see supabase/README.md).
    $defines = @()
    if (Test-Path supabase.json) { $defines += '--dart-define-from-file=supabase.json' }
    flutter build web --release --base-href /app/ --output landing/app @defines
} finally {
    Pop-Location
}
