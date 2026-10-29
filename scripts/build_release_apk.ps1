$env:FLUTTER_ROOT = "E:\flutter_windows_3.24.3-stable\flutter"
$env:PATH = "$env:FLUTTER_ROOT\bin;$env:PATH"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = "C:\Users\pc\AppData\Local\Android\Sdk"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$appDir = Join-Path $projectRoot "droid_recomp_app"
$targetApk = Join-Path $projectRoot "DroidRecomp-v1.0.0-release.apk"

Set-Location $appDir
Write-Host "Building Flutter release APK..."
& "$env:FLUTTER_ROOT\bin\flutter.bat" --no-version-check --suppress-analytics build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build succeeded! Copying APK to workspace root..."
    Copy-Item "build\app\outputs\flutter-apk\app-release.apk" $targetApk -Force
    $size = (Get-Item $targetApk).Length / 1MB
    Write-Host ("Copied release APK to root! Size: {0:N2} MB" -f $size)
} else {
    Write-Error "Flutter build failed with exit code $LASTEXITCODE"
}
