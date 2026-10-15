#requires -Version 7.0
param(
    [string]$BaseUrl = 'http://127.0.0.1:5080',
    [string]$CredencialesPath
)
$ErrorActionPreference = 'Stop'
$checks = [System.Collections.Generic.List[string]]::new()
$accounts = @()
$keepAccounts = $false
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../lib/firebase_options.dart') -Raw
$apiKey = [regex]::Match($config, "apiKey:\s*'([^']+)'").Groups[1].Value
$database = 'BancoSangreAcademico'

function Comprobar($condition, [string]$name) {
    if (-not $condition) { throw "FALLÓ: $name" }
    $checks.Add($name)
    Write-Host "[OK] $name"
}
function Peticion([string]$method, [string]$path, [string]$token = '', $body = $null) {
    $options = @{ Method=$method; Uri="$BaseUrl$path"; SkipHttpErrorCheck=$true; TimeoutSec=25 }
    if ($token) { $options.Headers = @{Authorization="Bearer $token"} }
    if ($null -ne $body) { $options.ContentType='application/json'; $options.Body=($body|ConvertTo-Json) }
    $response = Invoke-WebRequest @options
    $json = if($response.Content) { $response.Content | ConvertFrom-Json } else { $null }
    return @{ Status=[int]$response.StatusCode; Json=$json }
}
function Sql([string]$query) {
    $result = & sqlcmd -S '.\SQLEXPRESS' -E -C -d $database -b -W -h -1 -Q "SET NOCOUNT ON; $query"
    if ($LASTEXITCODE -ne 0) { throw 'Falló la comprobación directa de SQL Server.' }
    return ($result -join "`n").Trim()
}
function NuevaCuenta {
    $email = 'api-' + [guid]::NewGuid().ToString('N') + '@example.com'
    $password = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(24))
    $body = @{email=$email;password=$password;returnSecureToken=$true}|ConvertTo-Json
    $created = Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 25 -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey"
    return @{ email=$email; password=$password; uid=$created.localId; token=$created.idToken }
}
try {
    $bancos = Peticion GET '/api/bancos-sangre'
    Comprobar ($bancos.Status -eq 200 -and @($bancos.Json).Count -ge 2) 'GET bancos: catálogo real'
    Comprobar ((Peticion GET '/api/bancos-sangre/1').Json.id -eq 1) 'GET banco por ID'
    Comprobar ((Peticion GET '/api/bancos-sangre/999999').Status -eq 404) 'Banco inexistente: 404'
    Comprobar ((Sql "SELECT COUNT(*) FROM sys.tables WHERE name IN ('BancosSangre','Donantes','Citas')") -eq '3') 'Existen las tres tablas del negocio'
    Comprobar ((Peticion GET '/api/citas').Status -eq 401) 'Sin token: 401'
    Comprobar ((Peticion GET '/api/citas' 'token-invalido').Status -eq 401) 'Token inválido: 401'
    $accounts += NuevaCuenta
    $accounts += NuevaCuenta
    $a = $accounts[0]; $b = $accounts[1]
    $future = [DateTimeOffset]::UtcNow.AddDays(3).ToString('o')
    $valid = @{ bancoSangreId=1; fechaHora=$future }
    Comprobar ((Peticion POST '/api/citas' '' $valid).Status -eq 401) 'POST sin token: 401'
    Comprobar ((Peticion POST '/api/citas' $a.token @{bancoSangreId=999999;fechaHora=$future}).Status -eq 400) 'No permite banco inexistente'
    Comprobar ((Peticion POST '/api/citas' $a.token @{bancoSangreId=1;fechaHora='fecha-invalida'}).Status -eq 400) 'No permite fecha mal formada'
    Comprobar ((Peticion POST '/api/citas' $a.token @{bancoSangreId=1;fechaHora=[DateTimeOffset]::UtcNow.AddDays(-1).ToString('o')}).Status -eq 400) 'No permite fecha pasada'
    Comprobar ((Peticion POST '/api/citas' $a.token @{bancoSangreId=1}).Status -eq 400) 'Exige fecha y hora'
    $created = Peticion POST '/api/citas' $a.token $valid
    Comprobar ($created.Status -eq 201) 'CREATE: cita válida'
    $id = [int]$created.Json.id
    Comprobar ((Sql "SELECT COUNT(*) FROM Citas c JOIN Donantes d ON d.Id=c.DonanteId JOIN BancosSangre b ON b.Id=c.BancoSangreId WHERE c.Id=$id AND b.Id=1 AND d.FirebaseUid='$($a.uid)'") -eq '1') 'SQL confirma cita, banco y dueño del token'
    $sqlCreated = Sql "SELECT c.Id,c.DonanteId,c.BancoSangreId,CONVERT(varchar(40),c.FechaHora,127) AS FechaHora FROM Citas c WHERE c.Id=$id"
    Comprobar ((Peticion GET "/api/citas/$id" $a.token).Json.id -eq $id) 'READ: consulta propia'
    Comprobar (@((Peticion GET '/api/citas' $a.token).Json).Count -eq 1) 'Lista únicamente las citas propias'
    Comprobar ((Peticion POST '/api/citas' $a.token $valid).Status -eq 409) 'Evita reserva duplicada'
    Comprobar ((Peticion GET "/api/citas/$id" $b.token).Status -eq 404) 'Otro usuario no puede consultar la cita'
    Comprobar (@((Peticion GET '/api/citas' $b.token).Json | Where-Object { $null -ne $_ }).Count -eq 0) 'Otro usuario no recibe citas ajenas'
    Comprobar ((Peticion PUT "/api/citas/$id" $b.token $valid).Status -eq 404) 'Otro usuario no puede editar'
    Comprobar ((Peticion DELETE "/api/citas/$id" $b.token).Status -eq 404) 'Otro usuario no puede eliminar'
    $updated = @{bancoSangreId=2;fechaHora=[DateTimeOffset]::UtcNow.AddDays(4).ToString('o')}
    Comprobar ((Peticion PUT "/api/citas/$id" $a.token $updated).Status -eq 204) 'UPDATE: banco y fecha'
    Comprobar ((Sql "SELECT BancoSangreId FROM Citas WHERE Id=$id") -eq '2') 'SQL confirma la modificación'
    Comprobar ((Peticion GET "/api/citas/$id" $a.token).Json.bancoSangreId -eq 2) 'La API devuelve la modificación'
    Comprobar ((Peticion PUT "/api/citas/$id" $a.token @{bancoSangreId=999999;fechaHora=$future}).Status -eq 400) 'UPDATE rechaza banco inválido'
    Comprobar ((Peticion PUT "/api/citas/$id" $a.token @{bancoSangreId=1;fechaHora='2020-01-01T10:00:00Z'}).Status -eq 400) 'UPDATE rechaza fecha pasada'
    Comprobar ((Sql "SELECT BancoSangreId FROM Citas WHERE Id=$id") -eq '2') 'Los errores no alteran el registro anterior'
    Comprobar ((Peticion DELETE "/api/citas/$id" $a.token).Status -eq 204) 'DELETE: elimina cita propia'
    Comprobar ((Sql "SELECT COUNT(*) FROM Citas WHERE Id=$id") -eq '0') 'SQL confirma la eliminación'
    Comprobar ((Peticion GET "/api/citas/$id" $a.token).Status -eq 404) 'La cita eliminada ya no se consulta'
    @{ fecha=[DateTimeOffset]::Now.ToString('o'); tipo='API real + Firebase real + SQL Server Express';
       comprobaciones=$checks; filaSqlDuranteCreate=$sqlCreated; cantidad=$checks.Count } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'pruebas-api.json') -Encoding utf8
    if($CredencialesPath) {
        $fullPath = [IO.Path]::GetFullPath($CredencialesPath)
        if(-not $fullPath.StartsWith([IO.Path]::GetTempPath(), [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Las credenciales de prueba solo pueden guardarse en la carpeta temporal del usuario.'
        }
        @{a=$a;b=$b}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath $fullPath -Encoding utf8
        $keepAccounts = $true
    }
    Write-Host "Pasaron $($checks.Count) comprobaciones. No se imprimieron tokens ni contraseñas."
} finally {
    if(-not $keepAccounts) {
        foreach($account in $accounts) {
            if($account.uid -match '^[a-zA-Z0-9]+$') {
                $null = Sql "DELETE FROM Citas WHERE DonanteId IN (SELECT Id FROM Donantes WHERE FirebaseUid='$($account.uid)'); DELETE FROM Donantes WHERE FirebaseUid='$($account.uid)';"
            }
            $body=@{email=$account.email;password=$account.password;returnSecureToken=$true}|ConvertTo-Json
            $login=Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 25 -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey"
            $null=Invoke-RestMethod -Method Post -ContentType 'application/json' -Body (@{idToken=$login.idToken}|ConvertTo-Json) -TimeoutSec 25 -Uri "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$apiKey"
        }
    }
}

