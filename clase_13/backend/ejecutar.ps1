$ErrorActionPreference = 'Stop'
# Usa el SDK instalado en el usuario sin cambiar el PATH global de Windows.
$sdk = Join-Path $env:LOCALAPPDATA 'Microsoft/dotnet'
if(-not (Test-Path -LiteralPath (Join-Path $sdk 'sdk'))) {
    $sdk = Join-Path $env:LOCALAPPDATA 'Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Local/Microsoft/dotnet'
}
if(Test-Path -LiteralPath (Join-Path $sdk 'dotnet.exe')) {
    $env:DOTNET_ROOT = $sdk
    $env:PATH = "$sdk;$env:PATH"
}
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
Push-Location (Join-Path $PSScriptRoot 'BancoSangre.Api')
try {
    dotnet tool restore
    if($LASTEXITCODE -ne 0){throw 'No se pudo restaurar la herramienta de EF Core.'}
    dotnet ef database update
    if($LASTEXITCODE -ne 0){throw 'No se pudo aplicar la migración. Revisa el error anterior.'}
    dotnet run --launch-profile http
    if($LASTEXITCODE -ne 0){throw 'El backend no pudo iniciar. Revisa el error anterior.'}
} finally { Pop-Location }

