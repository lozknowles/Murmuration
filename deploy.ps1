[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9._@-]+$')]
    [string]$RemoteHost,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^/[A-Za-z0-9._/-]+$')]
    [string]$RemotePath,

    [ValidateRange(1, 65535)]
    [int]$Port = 22,

    [ValidatePattern('^https?://')]
    [string]$PublicUrl
)

$ErrorActionPreference = 'Stop'

if ($RemotePath -eq '/') {
    throw 'Refusing to deploy to the remote filesystem root.'
}

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexPath = Join-Path $projectRoot 'index.html'
$stylePath = Join-Path $projectRoot 'assets\murmuration.css'
$scriptPath = Join-Path $projectRoot 'assets\murmuration.js'

foreach ($requiredFile in @($indexPath, $stylePath, $scriptPath)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required release file is missing: $requiredFile"
    }
}

if (-not (Select-String -LiteralPath $indexPath -SimpleMatch 'id="murmuration"' -Quiet)) {
    throw 'index.html does not contain the Murmuration canvas.'
}

if (-not (Select-String -LiteralPath $scriptPath -SimpleMatch 'MAX_BIRD_COUNT = 10000' -Quiet)) {
    throw 'JavaScript does not contain the expected 10,000-bird release.'
}

Write-Host "Preparing $RemoteHost..."
& ssh -p $Port $RemoteHost "mkdir -p '$RemotePath/assets'"
if ($LASTEXITCODE -ne 0) { throw 'Could not prepare the remote directory.' }

& scp -P $Port $indexPath "${RemoteHost}:$RemotePath/index.html"
if ($LASTEXITCODE -ne 0) { throw 'HTML upload failed.' }

& scp -P $Port $stylePath $scriptPath "${RemoteHost}:$RemotePath/assets/"
if ($LASTEXITCODE -ne 0) { throw 'Asset upload failed.' }

if ($PublicUrl) {
    $baseUrl = $PublicUrl.TrimEnd('/')
    $pageResponse = Invoke-WebRequest -Uri "$baseUrl/" -UseBasicParsing
    $scriptResponse = Invoke-WebRequest -Uri "$baseUrl/assets/murmuration.js" -UseBasicParsing
    if ($pageResponse.StatusCode -ne 200 -or $pageResponse.Content -notmatch 'id="murmuration"') {
        throw 'Public HTML validation failed.'
    }
    if ($scriptResponse.StatusCode -ne 200 -or $scriptResponse.Content -notmatch 'MAX_BIRD_COUNT = 10000') {
        throw 'Public JavaScript validation failed.'
    }
}

Write-Host 'Deployment complete.'
if ($PublicUrl) { Write-Host "URL: $($PublicUrl.TrimEnd('/'))/" }
