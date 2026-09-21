# One-time: creates the Android release signing key and the values to paste into GitHub secrets.
# Everything is written to a temp folder; back it up to a password manager, then delete the folder.
# Losing this key means installed apps can no longer be updated in place.
$keytool = Join-Path $env:ProgramFiles 'Android\Android Studio\jbr\bin\keytool.exe'
if (-not (Test-Path $keytool)) { $keytool = 'keytool' }

$dir = Join-Path $env:TEMP 'messfellows-keystore'
New-Item -ItemType Directory -Force $dir | Out-Null
$jks = Join-Path $dir 'messfellows.jks'
if (Test-Path $jks) { throw "$jks already exists. Delete the folder $dir first." }

$chars = [char[]]'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
$password = -join (1..24 | ForEach-Object { $chars | Get-Random })

& $keytool -genkeypair -keystore $jks -storetype PKCS12 -alias messfellows -keyalg RSA -keysize 2048 `
    -validity 10000 -storepass $password -keypass $password -dname 'CN=Mess Fellows'
if ($LASTEXITCODE -ne 0) { throw 'keytool failed' }

[Convert]::ToBase64String([IO.File]::ReadAllBytes($jks)) | Set-Content -Encoding ascii (Join-Path $dir 'ANDROID_KEYSTORE_BASE64.txt')
$password | Set-Content -Encoding ascii (Join-Path $dir 'ANDROID_KEYSTORE_PASSWORD.txt')

Write-Host "`nCreated in: $dir"
Write-Host '  ANDROID_KEYSTORE_BASE64.txt   -> GitHub secret ANDROID_KEYSTORE_BASE64 (open, copy all, paste)'
Write-Host '  ANDROID_KEYSTORE_PASSWORD.txt -> GitHub secret ANDROID_KEYSTORE_PASSWORD'
Write-Host '  messfellows.jks               -> back this up (password manager / personal drive)'
Write-Host 'Then delete the folder from this computer.'
