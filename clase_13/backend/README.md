# Backend del Banco de Sangre

## Alcance actual

Se conserva la API ASP.NET Core con EF Core, SQL Server y validación de Firebase ID Tokens.
Flutter conserva las pantallas originales y sus funciones de Firebase Authentication y Firestore.
Se retiraron las tres interfaces añadidas para bancos, formulario de citas y Mis citas,
sus accesos, rutas y código exclusivo. No se modificó el diseño de las pantallas originales.

**Las pantallas originales no incluyen gestión de citas con bancos. Actualmente ninguna de ellas
consume los endpoints C# de citas. Ese CRUD se demuestra mediante Swagger/OpenAPI,
solicitudes HTTP y consultas reales a SQL Server.** Una solicitud de sangre no es una cita;
registrar un donante en Firestore tampoco agenda una cita en SQL.

| Pantallas originales | Servicio que conservan | Motivo |
|---|---|---|
| Splash y Onboarding | Navegación local | No necesitan operaciones SQL. |
| Login, registro y recuperación | Firebase Authentication | Se conserva el único sistema de acceso. |
| Home, perfil y edición | Firebase y Firestore | Ya funcionan con su lógica original. |
| Registro y búsqueda de donantes | Firestore | Perfil y disponibilidad; no reservas de citas. |
| Solicitudes de sangre y sus detalles | Firestore | Publicación y cierre de solicitudes, con un significado distinto a una cita. |

## Base de datos y archivos conservados

Base: `BancoSangreAcademico`, instancia local `.\SQLEXPRESS`.

| Tabla | Campos principales | Relación |
|---|---|---|
| BancosSangre | Id, Nombre, Direccion, Telefono | Un banco puede tener muchas citas. |
| Donantes | Id, FirebaseUid único | Vínculo mínimo con Firebase; un donante puede tener muchas citas. |
| Citas | Id, DonanteId, BancoSangreId, FechaHora | Cada cita pertenece a un donante y un banco. |

No se guardan contraseñas ni perfiles médicos en SQL. Los perfiles originales siguen en Firestore.
Las claves foráneas evitan citas sin banco o donante. No hay borrado en cascada.
Un índice evita citas simultáneas duplicadas para el mismo donante.
Los dos bancos iniciales son ficticios y están identificados como bancos de práctica.
`__EFMigrationsHistory` es una tabla técnica, no una cuarta tabla del negocio.

Dentro de `backend/BancoSangre.Api`:

| Archivo | Función |
|---|---|
| Program.cs | Registra DbContext/SQL Server, Controllers, Firebase JWT, errores y Swagger. |
| Controllers/BancosSangreController.cs | Consulta bancos en SQL mediante EF Core. |
| Controllers/CitasController.cs | Consulta citas propias y realiza CREATE, UPDATE y DELETE. |
| Models/BancoSangre.cs | Datos del banco. |
| Models/Donante.cs | ID SQL y FirebaseUid. |
| Models/Cita.cs | Relación con donante, banco y fecha/hora. |
| Data/BancoSangreDbContext.cs | Configura tablas, relaciones, índices y datos iniciales de práctica. |
| DTOs/CitasDtos.cs | Valida las entradas y define las respuestas sin exponer el UID. |
| BancoSangre.Api.csproj | Dependencias oficiales de ASP.NET Core, EF Core y SQL Server; Swagger. |
| appsettings.json | Proyecto público de Firebase y configuración general. |
| appsettings.Development.json | Conexión local con autenticación de Windows, sin contraseña. |
| Properties/launchSettings.json | Arranque local en 127.0.0.1:5080. |
| .config/dotnet-tools.json | Versión reproducible de la herramienta dotnet-ef. |
| Migrations/ | Inicial crea tablas; CambiarGuionesBancos actualiza nombres. Se conservan sus metadatos y snapshot. |

También se conservan `backend/ejecutar.ps1`, `backend/probar-api.ps1` y los resultados
de pruebas existentes. No se retiró ningún archivo del proyecto C#, migración ni prueba REST.
Los Controllers utilizan directamente el DbContext; no hay repositorios ni capas adicionales.

## Ejecutar

En esta PC están disponibles .NET SDK 10, SQL Server Express, Flutter, Android SDK y sqlcmd.
Desde la carpeta raíz Flutter, en PowerShell:

```powershell
./backend/ejecutar.ps1
```

El script localiza el SDK, restaura dotnet-ef, aplica las migraciones incluidas e inicia la API.
No vuelve a generar la migración inicial. No borra ni reinicia la base de datos.
La cuenta de Windows debe tener acceso a SQL Express y permiso de creación si se instala en otra PC.

Cadena local configurada en appsettings.Development.json:

```text
Server=.\SQLEXPRESS;Database=BancoSangreAcademico;Trusted_Connection=True;Encrypt=True;TrustServerCertificate=True
```

`Program.cs` lee esta cadena y registra `UseSqlServer`. `TrustServerCertificate=True` se autorizó
para el certificado de este SQL local y mantiene el cifrado. No es la configuración de un servidor público.
Una conexión diferente se configura con `ConnectionStrings__BancoSangre` o User Secrets;
no se deben guardar contraseñas reales en archivos del proyecto.

Swagger: http://127.0.0.1:5080/swagger

Flutter se ejecuta por separado con `flutter run -d emulator-5554`.
Las pantallas actuales utilizan Firebase/Firestore; no necesitan API_BASE_URL.
Se retiró el cliente HTTP de citas porque no tenía consumidores en pantallas originales,
junto con su dependencia directa y la excepción Android de HTTP local que lo acompañaba.
No se cambiaron Windows Firewall ni las reglas de Firebase.

## Endpoints y autenticación

| Método y ruta | Operación |
|---|---|
| GET /api/bancos-sangre | Catálogo público. |
| GET /api/bancos-sangre/{id} | Banco por ID. |
| GET /api/citas | Citas del usuario autenticado. |
| GET /api/citas/{id} | Una cita propia. |
| POST /api/citas | Registrar cita. |
| PUT /api/citas/{id} | Cambiar banco y fecha/hora. |
| DELETE /api/citas/{id} | Eliminar cita propia. |

POST y PUT reciben únicamente:

```json
{"bancoSangreId":1,"fechaHora":"2027-01-20T14:30:00Z"}
```

Los endpoints protegidos reciben `Authorization: Bearer ID_TOKEN`. El middleware JwtBearer
comprueba firma RS256 con las claves públicas de Google, emisor, audiencia, caducidad y sub.
El proyecto esperado es `donar-sangre-intec`. El dueño se obtiene del token validado;
no se acepta un UID ni DonanteId elegido libremente desde el cliente.
No se agregó un login en C# ni se almacenan contraseñas en SQL.

Respuestas: 200 consulta, 201 alta, 204 edición/eliminación, 400 campos/fecha/banco inválidos,
401 token ausente o inválido, 404 registro inexistente o cita ajena, 409 reserva duplicada.

### Probar con Swagger

1. Abre Swagger y ejecuta GET /api/bancos-sangre; después GET por ID.
2. Para citas, utiliza Authorize con el Firebase ID Token vigente de una cuenta de prueba.
   Pega únicamente el token: Swagger añade el encabezado Bearer.
3. Ejecuta POST con banco y fecha futura; anota el ID devuelto.
4. Consulta ese ID, modifícalo con PUT y vuelve a consultar SQL.
5. Elimina únicamente la cita temporal con DELETE y verifica que desaparece.

Si necesitas obtener el token manualmente sin añadir pantallas ni imprimir credenciales,
puedes usar PowerShell con una cuenta de Firebase de prueba:

```powershell
$config = Get-Content ./lib/firebase_options.dart -Raw
$apiKey = [regex]::Match($config, "apiKey:\s*'([^']+)'").Groups[1].Value
$cuenta = Get-Credential -Message 'Cuenta de Firebase de prueba'
$datos = @{email=$cuenta.UserName; password=$cuenta.GetNetworkCredential().Password; returnSecureToken=$true} | ConvertTo-Json
$sesion = Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $datos -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey"
Set-Clipboard -Value $sesion.idToken
```

Pega el token en Authorize y limpia el portapapeles al terminar. No lo incluyas en capturas, logs
ni archivos del proyecto. Esta solicitud inicia sesión en Firebase; no es un segundo sistema de acceso.

## Verificar SQL y repetir las pruebas

En SQL Server Management Studio: servidor `.\SQLEXPRESS`, autenticación de Windows.
Selecciona BancoSangreAcademico y abre New Query:

```sql
SELECT name FROM sys.tables;

SELECT c.Id, c.DonanteId, c.BancoSangreId, b.Nombre AS Banco, c.FechaHora
FROM dbo.Citas c
JOIN dbo.Donantes d ON d.Id = c.DonanteId
JOIN dbo.BancosSangre b ON b.Id = c.BancoSangreId
ORDER BY c.Id;
```

Las consultas están en los Controllers; EF Core las convierte en SQL parametrizado.
`SaveChangesAsync` guarda los cambios en `BancoSangreAcademico.dbo.Citas`.

Con la API encendida, desde la raíz y en PowerShell 7:

```powershell
./backend/probar-api.ps1
```

Este script se conserva completo. Crea dos cuentas temporales de Firebase, ejecuta 29 comprobaciones
reales contra la API y SQL, y limpia exclusivamente sus citas, vínculos SQL y cuentas de prueba.
Prueba CREATE/READ/UPDATE/DELETE, fechas, banco inexistente, duplicados, falta de token y
prohibición de consultar, modificar o eliminar citas ajenas. Guarda `backend/pruebas-api.json`.

Validaciones de Flutter:

```text
flutter analyze
flutter test
flutter build apk --debug
```

Se conservan las 12 pruebas originales y `integration_test/firebase_flow_test.dart` con su driver.
Las cinco pruebas MockClient y la prueba de navegación de citas se retiraron con el cliente y
las pantallas exclusivos que verificaban. No se eliminaron pruebas REST ni verificaciones SQL del backend.
La prueba real de Firebase valida login, registro, perfil de donante, publicación y cierre de solicitud.
Usa una cuenta temporal con TEST_EMAIL y TEST_PASSWORD; nunca una cuenta de otra persona.
Las solicitudes sintéticas quedan cerradas conforme a las reglas actuales de Firestore,
que no permiten borrarlas; no se debilitan esas reglas para limpiar la prueba.

Los JSON `pruebas-sql-flutter.json`, `pruebas-persistencia.json` y las capturas de
`revision_final_20261015` documentan la versión anterior. Se conservan como evidencia histórica;
no representan las pantallas actuales. El resultado vigente de la API está en `pruebas-api.json`.

## Validación después del retiro de las pantallas

- Flutter analyze: sin incidencias; flutter test: las 12 pruebas originales aprobadas.
- Prueba real Android/Firebase/Firestore aprobada: login, registro, perfil de donante y solicitud de sangre.
- APK debug normal compilado e instalado en el emulador.
- C# compila con 0 errores y 0 advertencias; 29 comprobaciones reales de la API aprobadas.
- Los 20 archivos del proyecto C# y scripts de ejecución/pruebas conservan sus huellas anteriores.
- Los registros existentes de las tres tablas coinciden exactamente con el estado previo a la corrección.
- main.dart, Home, HomeDrawer, manifiesto debug, pubspec.yaml y pruebas originales coinciden con el respaldo
  anterior al backend. Se conserva la corrección de escritura Case a Cause realizada posteriormente.

## Explicación para la defensa

«Conservamos las pantallas del profesor. Flutter utiliza Firebase para iniciar sesión y Firestore
para perfiles y solicitudes de sangre. No convertimos esas solicitudes en citas porque tienen
un significado distinto. El backend académico se demuestra mediante Swagger y SQL Server.

La API REST está escrita en C# con ASP.NET Core. Los Controllers reciben solicitudes HTTP,
validan los datos y usan el DbContext de Entity Framework Core para consultar y guardar.
Hay tres tablas: bancos, donantes y citas. Cada cita tiene claves foráneas hacia un banco y
un donante. SQL guarda únicamente el FirebaseUid necesario para relacionar la identidad.

Firebase sigue siendo el único sistema de autenticación. La API comprueba el ID token y
permite a cada usuario gestionar únicamente sus propias citas. Demostramos el CRUD
registrando una cita temporal, consultándola en SQL, modificándola y eliminándola.
No añadimos interfaces de citas porque no forman parte de las pantallas entregadas».

