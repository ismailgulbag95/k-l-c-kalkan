$ErrorActionPreference = 'Stop'

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$androidDirectory = Join-Path $projectRoot 'android'
$localPropertiesPath = Join-Path $androidDirectory 'key.properties'
$localValues = @{}

if (Test-Path -LiteralPath $localPropertiesPath -PathType Leaf) {
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadAllLines($localPropertiesPath)) {
        $lineNumber++
        $trimmedLine = $line.Trim()
        if ($trimmedLine.Length -eq 0 -or $trimmedLine.StartsWith('#') -or $trimmedLine.StartsWith('!')) {
            continue
        }

        $separatorIndex = $line.IndexOf('=')
        if ($separatorIndex -lt 1) {
            throw "Invalid android/key.properties syntax at line $lineNumber; expected key=value."
        }

        $name = $line.Substring(0, $separatorIndex).Trim()
        $value = $line.Substring($separatorIndex + 1).Trim()
        $localValues[$name] = $value
    }
}

function Get-StoreValue([string]$EnvironmentName, [string]$PropertyName) {
    $environmentValue = [System.Environment]::GetEnvironmentVariable($EnvironmentName, 'Process')
    if (-not [string]::IsNullOrWhiteSpace($environmentValue)) {
        return $environmentValue
    }

    if ($localValues.ContainsKey($PropertyName) -and
        -not [string]::IsNullOrWhiteSpace([string]$localValues[$PropertyName])) {
        return [string]$localValues[$PropertyName]
    }

    return $null
}

$applicationId = Get-StoreValue 'STORE_APPLICATION_ID' 'storeApplicationId'
$keystorePath = Get-StoreValue 'STORE_KEYSTORE_PATH' 'storeFile'
$keyAlias = Get-StoreValue 'STORE_KEY_ALIAS' 'keyAlias'
$keystorePassword = Get-StoreValue 'STORE_KEYSTORE_PASSWORD' 'storePassword'
$keyPassword = Get-StoreValue 'STORE_KEY_PASSWORD' 'keyPassword'

$missingValues = [System.Collections.Generic.List[string]]::new()
if ([string]::IsNullOrWhiteSpace($applicationId)) { $missingValues.Add('publisher application ID') }
if ([string]::IsNullOrWhiteSpace($keystorePath)) { $missingValues.Add('keystore path') }
if ([string]::IsNullOrWhiteSpace($keyAlias)) { $missingValues.Add('key alias') }
if ([string]::IsNullOrWhiteSpace($keystorePassword)) { $missingValues.Add('keystore password') }
if ([string]::IsNullOrWhiteSpace($keyPassword)) { $missingValues.Add('key password') }
if ($missingValues.Count -gt 0) {
    throw "Store Android build requires: $($missingValues -join ', '). Supply values in android/key.properties or the documented environment variables."
}

if ($applicationId -notmatch '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$') {
    throw 'STORE_APPLICATION_ID must be a valid, publisher-selected Android package ID.'
}
if ($applicationId -eq 'com.example' -or $applicationId.StartsWith('com.example.', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'STORE_APPLICATION_ID must not use Android''s sample com.example namespace.'
}

$resolvedKeystorePath = if ([System.IO.Path]::IsPathRooted($keystorePath)) {
    [System.IO.Path]::GetFullPath($keystorePath)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $androidDirectory $keystorePath))
}
if (-not (Test-Path -LiteralPath $resolvedKeystorePath -PathType Leaf)) {
    throw 'The configured store keystore file does not exist.'
}

if (-not (Get-Command 'flutter' -ErrorAction SilentlyContinue)) {
    throw 'Flutter was not found on PATH.'
}

$gradleProperties = @{
    ORG_GRADLE_PROJECT_storeRelease = 'true'
    ORG_GRADLE_PROJECT_storeApplicationId = $applicationId
    ORG_GRADLE_PROJECT_storeKeystorePath = $resolvedKeystorePath
    ORG_GRADLE_PROJECT_storeKeyAlias = $keyAlias
    ORG_GRADLE_PROJECT_storeKeystorePassword = $keystorePassword
    ORG_GRADLE_PROJECT_storeKeyPassword = $keyPassword
}
$previousEnvironment = @{}
foreach ($name in $gradleProperties.Keys) {
    $previousEnvironment[$name] = [System.Environment]::GetEnvironmentVariable($name, 'Process')
    [System.Environment]::SetEnvironmentVariable($name, $gradleProperties[$name], 'Process')
}

try {
    Push-Location -LiteralPath $projectRoot
    try {
        Write-Host 'Building the store-signed Android App Bundle...'
        & flutter build appbundle --release
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter store App Bundle build failed with exit code $LASTEXITCODE."
        }

        $artifactPath = Join-Path $projectRoot 'build\app\outputs\bundle\release\app-release.aab'
        if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
            throw 'Flutter reported success but the expected App Bundle was not created.'
        }

        Get-Item -LiteralPath $artifactPath | Select-Object FullName, Length
    }
    finally {
        Pop-Location
    }
}
finally {
    foreach ($name in $gradleProperties.Keys) {
        [System.Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], 'Process')
    }
}
