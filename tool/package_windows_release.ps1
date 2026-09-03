param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^v\d+\.\d+\.\d+$')]
    [string]$Version
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$releaseDirectory = Join-Path $repositoryRoot 'build\windows\x64\runner\Release'
$executablePath = Join-Path $releaseDirectory 'flutter_system_manager.exe'

if (-not (Test-Path -LiteralPath $executablePath)) {
    throw 'Windows release build not found. Run flutter build windows --release first.'
}

$distDirectory = Join-Path $repositoryRoot 'dist'
$packageName = "Flutter-System-Manager-Windows-x64-$Version"
$stagingDirectory = Join-Path $distDirectory $packageName
$archivePath = Join-Path $distDirectory "$packageName.zip"
$checksumPath = Join-Path $distDirectory "$packageName.sha256"

$repositoryRootPath = [System.IO.Path]::GetFullPath($repositoryRoot).TrimEnd('\') + '\'
$distDirectoryPath = [System.IO.Path]::GetFullPath($distDirectory).TrimEnd('\') + '\'
$stagingDirectoryPath = [System.IO.Path]::GetFullPath($stagingDirectory)

if (-not $distDirectoryPath.StartsWith($repositoryRootPath, [System.StringComparison]::OrdinalIgnoreCase) -or
    -not $stagingDirectoryPath.StartsWith($distDirectoryPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to package files outside the repository dist directory.'
}

New-Item -ItemType Directory -Force -Path $distDirectory | Out-Null

if (Test-Path -LiteralPath $stagingDirectory) {
    Remove-Item -LiteralPath $stagingDirectory -Recurse -Force
}
if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}
if (Test-Path -LiteralPath $checksumPath) {
    Remove-Item -LiteralPath $checksumPath -Force
}

New-Item -ItemType Directory -Path $stagingDirectory | Out-Null
Copy-Item -Path (Join-Path $releaseDirectory '*') -Destination $stagingDirectory -Recurse
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'README.md') -Destination $stagingDirectory

$licensePath = Join-Path $repositoryRoot 'LICENSE'
if (Test-Path -LiteralPath $licensePath) {
    Copy-Item -LiteralPath $licensePath -Destination $stagingDirectory
}

Compress-Archive -Path (Join-Path $stagingDirectory '*') -DestinationPath $archivePath

$archiveName = Split-Path -Leaf $archivePath
$checksum = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
"$checksum  $archiveName" | Set-Content -LiteralPath $checksumPath -Encoding ascii

Remove-Item -LiteralPath $stagingDirectory -Recurse -Force

Write-Output "Created $archivePath"
Write-Output "Created $checksumPath"
