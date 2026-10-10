param(
    [ValidateSet('apk', 'appbundle')]
    [string]$Format = 'apk'
)

$ErrorActionPreference = 'Stop'

$sourceDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$parentDirectory = [System.IO.Path]::GetFullPath((Split-Path $sourceDirectory -Parent))
$buildDirectory = Join-Path $parentDirectory (
    'ash_circuit_android_build_{0}' -f [guid]::NewGuid().ToString('N')
)
$artifactRelativePath = if ($Format -eq 'apk') {
    'build\app\outputs\flutter-apk\app-release.apk'
} else {
    'build\app\outputs\bundle\release\app-release.aab'
}
$outputDirectory = Split-Path (Join-Path $sourceDirectory $artifactRelativePath) -Parent
$artifactName = Split-Path $artifactRelativePath -Leaf

try {
    $robocopyArguments = @(
        $sourceDirectory,
        $buildDirectory,
        '/E',
        '/XD', '.dart_tool', 'build', '.git', '.gradle',
        '/R:2', '/W:1', '/NFL', '/NDL', '/NJH', '/NJS'
    )
    & robocopy.exe @robocopyArguments
    if ($LASTEXITCODE -gt 7) {
        throw "Project copy failed with robocopy exit code $LASTEXITCODE."
    }

    Push-Location -LiteralPath $buildDirectory
    try {
        & flutter build $Format --release
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter Android build failed with exit code $LASTEXITCODE."
        }

        $artifact = Join-Path $buildDirectory $artifactRelativePath
        if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) {
            throw 'Flutter reported success but the APK was not created.'
        }

        New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
        $destination = Join-Path $outputDirectory $artifactName
        Copy-Item -LiteralPath $artifact -Destination $destination -Force
        Get-Item -LiteralPath $destination | Select-Object FullName, Length
    }
    finally {
        Pop-Location
    }
}
finally {
    $resolvedParent = [System.IO.Path]::GetFullPath($parentDirectory).TrimEnd('\')
    $resolvedBuild = [System.IO.Path]::GetFullPath($buildDirectory)
    $allowedPrefix = Join-Path $resolvedParent 'ash_circuit_android_build_'
    if ($resolvedBuild.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedBuild -PathType Container)) {
        Remove-Item -LiteralPath $resolvedBuild -Recurse -Force
    }
}
