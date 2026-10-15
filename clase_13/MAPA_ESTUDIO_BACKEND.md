# Banco de Sangre: mapa del código para estudiar y defender

Revisión del código actual: 15 de octubre de 2026. Las líneas indicadas corresponden al código después de añadir los comentarios de estudio; son aproximadas si posteriormente editas los archivos.

## 1. Qué existe realmente

Hay un solo proyecto ASP.NET Core Web API: `backend/BancoSangre.Api/BancoSangre.Api.csproj`. Usa .NET 10, C#, Entity Framework Core con el proveedor de SQL Server, JwtBearer para validar Firebase ID Tokens y Swashbuckle para Swagger.

El backend administra bancos y citas en SQL Server. Flutter mantiene sus pantallas y utiliza Firebase Authentication y Firestore para usuarios, perfiles, donantes disponibles y solicitudes de sangre. **Actualmente ningún archivo Dart consume los endpoints C# de citas**: sus pantallas y cliente HTTP exclusivos fueron retirados. Compartir el proyecto de Firebase permite reconocer la misma identidad, pero no significa que Flutter esté enviando citas a esta API.

Una solicitud de sangre en Firestore no es una cita en SQL. La demostración actual del CRUD de citas se realiza con Swagger o solicitudes HTTP.

## 2. Los 15 puntos del mapa

Todas las rutas parten de la carpeta que contiene `pubspec.yaml`. En las filas de C#, el prefijo `backend/BancoSangre.Api/` forma parte de la ruta.

| # | Qué localizar | Archivo exacto | Método, miembro o bloque real | Línea aproximada |
| --- | --- | --- | --- | --- |
| 1 | Inicio del backend | `backend/BancoSangre.Api/Program.cs` | Código de nivel superior: `WebApplication.CreateBuilder(args)`, `builder.Build()` y `app.Run()`; no hay un método Main escrito manualmente. | 7, 70 y 84 |
| 2 | Conexión a SQL Server | `backend/BancoSangre.Api/Program.cs`; `backend/BancoSangre.Api/appsettings.Development.json` | `GetConnectionString("BancoSangre")`, `AddDbContext<BancoSangreDbContext>` y `UseSqlServer(connection)`; valor `ConnectionStrings:BancoSangre`. | 12-14; 3 |
| 3 | DbContext y acceso a tablas | `backend/BancoSangre.Api/Data/BancoSangreDbContext.cs` | Clase `BancoSangreDbContext`; propiedades `BancosSangre`, `Donantes`, `Citas`. | 6 y 9-11 |
| 4 | Las tres entidades | `backend/BancoSangre.Api/Models/BancoSangre.cs`; `Models/Donante.cs`; `Models/Cita.cs` dentro del mismo proyecto | Clases `BancoSangre`, `Donante`, `Cita`. | 3 en cada archivo |
| 5 | Relaciones, restricciones e índices | `backend/BancoSangre.Api/Data/BancoSangreDbContext.cs` | `OnModelCreating`; `HasOne(...).WithMany().HasForeignKey(...)`, `OnDelete(DeleteBehavior.Restrict)` y `HasIndex(...).IsUnique()`. | 13, 35 y 42-47 |
| 6 | CREATE: crear cita | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `Crear`: llama a `Validar`, obtiene o crea el vínculo del donante, ejecuta `db.Citas.Add(cita)` y devuelve `CreatedAtAction`. | 51-71 |
| 7 | READ: consultar citas | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `Listar` y `Obtener`, apoyados en `MisCitas` y `Respuesta`. | 39, 43; auxiliares 21 y 25 |
| 8 | UPDATE: modificar cita | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `Modificar`: encuentra la cita propia y permite cambiar banco y fecha. | 75-89 |
| 9 | DELETE: eliminar cita | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `Eliminar`: busca la cita propia y ejecuta `db.Citas.Remove(cita)`. | 93-102 |
| 10 | Guardar cambios en SQL | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `db.SaveChangesAsync(ct)` dentro de `Crear`, `Modificar` y `Eliminar`. | 64, 85 y 100 |
| 11 | Validar Firebase Authentication | `backend/BancoSangre.Api/Program.cs` | `AddAuthentication(...).AddJwtBearer(...)`, `TokenValidationParameters`, `OnTokenValidated`; después `UseAuthentication` y `UseAuthorization`. | 22-52 y 80-81 |
| 12 | Obtener identidad del usuario | `backend/BancoSangre.Api/Controllers/CitasController.cs` | Propiedad `Uid`: `User.FindFirstValue("sub")`. El evento `OnTokenValidated` comprueba que ese claim sea válido. | 18; validación en Program.cs 43-49 |
| 13 | Impedir acceso a citas ajenas | `backend/BancoSangre.Api/Controllers/CitasController.cs` | `[Authorize]`; filtro de `MisCitas`; filtros por `id` y `c.Donante.FirebaseUid == Uid` en `Modificar` y `Eliminar`. | 13, 21-22, 77 y 95 |
| 14 | Prueba manual con Swagger | `backend/BancoSangre.Api/Program.cs`; `backend/BancoSangre.Api/Properties/launchSettings.json`; `backend/README.md` | `AddSwaggerGen`, `UseSwagger`, `UseSwaggerUI`; perfil `http`; sección “Probar con Swagger”. | 56, 76-77; 6; README 121 |
| 15 | Conexión actual de Flutter | `lib/main.dart`; `lib/src/services/firebase_blood_repository.dart` | `main` inicializa Firebase y crea `FirebaseBloodRepository`. Sus métodos `login`, `saveProfile`, `watchRequests`, `createRequest`, etc. llaman Firebase/Firestore, no la API C#. | main.dart 18-24; repositorio 18, 70 y 93-108 |

## 3. Archivos importantes y orden de lectura

Existen **13 archivos C# de código fuente**, excluyendo `bin` y `obj`:

| Grupo | Archivos | Para qué sirven |
| --- | --- | --- |
| Inicio | `backend/BancoSangre.Api/Program.cs` | Registra dependencias, SQL Server, autenticación, autorización, errores, documentación y rutas. |
| Controllers (2) | `Controllers/CitasController.cs`, `Controllers/BancosSangreController.cs` | Reciben HTTP y consultan/guardan mediante el DbContext. |
| Models (3) | `Models/BancoSangre.cs`, `Models/Donante.cs`, `Models/Cita.cs` | Representan los datos persistidos y las relaciones. |
| Data (1) | `Data/BancoSangreDbContext.cs` | Expone tablas y configura el modelo de EF Core. |
| DTOs (1 archivo) | `DTOs/CitasDtos.cs` | Contiene `BancoSangreDto`, `GuardarCitaDto` y `CitaDto`. Define entradas válidas y respuestas limitadas. |
| Migraciones (5) | Los cinco `.cs` de `Migrations/` | Dos migraciones, dos archivos Designer y un snapshot. Son generados por EF Core. |

Las rutas abreviadas de esta tabla están dentro de `backend/BancoSangre.Api/`.

Estudia primero los tres Models; después DbContext y DTOs; sigue con los dos Controllers; termina con Program.cs, migraciones y pruebas. Son **8 archivos principales escritos para la aplicación** y **5 generados**. No necesitas memorizar los Designer.

No hay una clase separada de “servicio de autenticación Firebase” en C#: la configuración está en Program.cs. Tampoco existe un proyecto C# de pruebas unitarias con xUnit/NUnit.

## 4. Tablas y relaciones reales

| Tabla | Campos actuales | Regla principal |
| --- | --- | --- |
| `BancosSangre` | `Id`, `Nombre`, `Direccion`, `Telefono` | Un banco puede tener muchas citas. Los dos bancos iniciales son ficticios de práctica. |
| `Donantes` | `Id`, `FirebaseUid` | El UID es obligatorio, único y se compara respetando mayúsculas. No duplica el perfil completo de Firestore. |
| `Citas` | `Id`, `DonanteId`, `BancoSangreId`, `FechaHora` | Cada cita pertenece a un donante y a un banco. La combinación donante/fecha es única. |

`Id` es la clave primaria de cada entidad. `DonanteId` y `BancoSangreId` son claves foráneas. Las migraciones muestran columnas IDENTITY y las restricciones que crea SQL Server. `WithMany()` define relaciones de uno a muchos aunque las clases no tengan una lista de citas. `Restrict` evita el borrado en cascada del banco o donante relacionado.

No hay columna Estado: DELETE elimina físicamente la cita. No elimina el banco ni el donante. No hay contraseñas ni información clínica en estas tablas. `__EFMigrationsHistory` es una tabla técnica de EF, no una cuarta tabla del negocio.

En `Migrations/20261015135442_Inicial.cs`, `Up` (línea 14) crea tablas, relaciones, índices y los bancos ficticios; `Down` (99) describe la reversión. `20261015150551_CambiarGuionesBancos.cs`, `Up` (11), únicamente cambia el guion de los nombres iniciales. Los dos Designer contienen `BuildTargetModel` (19); el snapshot contiene `BuildModel` (16). No se ejecutaron migraciones durante esta preparación.

## 5. Endpoints reales

| Método y ruta | Controller y método | Acceso / respuesta satisfactoria |
| --- | --- | --- |
| `GET /api/bancos-sangre` | `BancosSangreController.Listar` (13) | Público, 200. |
| `GET /api/bancos-sangre/{id}` | `BancosSangreController.Obtener` (21) | Público, 200; inexistente, 404. |
| `GET /api/citas` | `CitasController.Listar` (39) | Token válido, lista propia, 200. |
| `GET /api/citas/{id}` | `CitasController.Obtener` (43) | Cita propia, 200; inexistente o ajena, 404. |
| `POST /api/citas` | `CitasController.Crear` (51) | Token válido, 201 con respuesta y ubicación del recurso. |
| `PUT /api/citas/{id}` | `CitasController.Modificar` (75) | Cita propia, 204 sin cuerpo. |
| `DELETE /api/citas/{id}` | `CitasController.Eliminar` (93) | Cita propia, 204 sin cuerpo. |

Las rutas base están en `[Route("api/citas")]` y `[Route("api/bancos-sangre")]`; los atributos `[HttpGet]`, `[HttpPost]`, `[HttpPut]` y `[HttpDelete]` seleccionan la acción. `MapControllers` publica esas rutas.

No hay CRUD administrativo completo de bancos ni de donantes.

POST y PUT reciben `GuardarCitaDto`, definido en `DTOs/CitasDtos.cs:8`:

```json
{
  "bancoSangreId": 1,
  "fechaHora": "2027-01-20T14:30:00Z"
}
```

Utiliza una fecha que siga siendo futura cuando hagas la demostración. El ejemplo utiliza UTC (`Z`). `Validar` comprueba fecha futura y existencia del banco; los atributos `[Required]` y `[Range]` y `[ApiController]` rechazan entradas inválidas. El Controller convierte la fecha a UTC antes de guardarla.

Errores relevantes: 400 por entrada inválida; 401 por token ausente/inválido; 404 por cita inexistente o ajena; 409 por conflicto de unicidad. Las respuestas no incluyen el FirebaseUid. `CitaDto` está en `DTOs/CitasDtos.cs:17`.

## 6. Cómo funciona CREATE de principio a fin

1. Swagger o un cliente HTTP envía POST con JSON y `Authorization: Bearer <ID_TOKEN>`.
2. JwtBearer valida el token. La autorización de `CitasController` exige una identidad válida.
3. ASP.NET Core construye y valida `GuardarCitaDto`.
4. `Crear` llama `Validar` y obtiene el UID desde el token; el cliente no elige al dueño.
5. Busca `Donante` por UID y crea ese vínculo mínimo si todavía no existe.
6. Construye `Cita` y la agrega al contexto. `Add` todavía no confirma la escritura en SQL.
7. `SaveChangesAsync` guarda los cambios; si hace falta crear el donante, donante y cita se guardan juntos. Las restricciones de SQL también se aplican aquí.
8. `Respuesta` consulta la proyección `CitaDto` y `CreatedAtAction(nameof(Obtener), ...)` devuelve 201.

Los Controllers contienen consultas LINQ, no procedimientos almacenados. EF Core las transforma en SQL. `ToListAsync`, `SingleOrDefaultAsync`, `SingleAsync` y `AnyAsync` ejecutan las consultas. `SaveChangesAsync` ejecuta las escrituras pendientes. Los filtros y proyecciones no requieren cargar todo el banco o donante mediante Include.

`AsNoTracking` se usa en lecturas para no seguir cambios de esas entidades. En modificación y eliminación se consulta una entidad rastreada, se cambia o elimina y luego se guarda. `async/await` permite esperar la operación de entrada/salida sin bloquear el hilo durante esa espera; `CancellationToken ct` permite propagar la cancelación.

## 7. Autenticación y aislamiento

Firebase Authentication es el único sistema de login. En Program.cs, `AddJwtBearer` usa el proyecto configurado en `appsettings.json:3` y el emisor `https://securetoken.google.com/{project}`. Verifica firma RS256 con las claves públicas de Google, emisor, audiencia y vigencia. `OnTokenValidated` exige un claim `sub` no vacío y de longitud permitida. No usa una clave privada de servicio de Firebase.

`Uid` lee `sub` del token ya validado. `GuardarCitaDto` no contiene FirebaseUid ni DonanteId. Para leer se usa `MisCitas`; para modificar/eliminar se filtra por ID y UID en la misma consulta. Que una cita ajena responda 404 evita confirmar su existencia al solicitante. La validación JWT actual no implementa una comprobación adicional de revocación contra Firebase por cada petición.

No confundas autenticar (identificar la cuenta) con autorizar (permitirle operar sobre una cita concreta). El filtro por propietario sigue siendo necesario después de validar el token.

## 8. Configuración, ejecución y demostración

La conexión de desarrollo usa `.\SQLEXPRESS`, base `BancoSangreAcademico`, autenticación integrada de Windows y cifrado; no contiene usuario SQL ni contraseña. `TrustServerCertificate=True` es la configuración ya autorizada para el certificado local. `appsettings.json` contiene el ID público del proyecto Firebase. `Properties/launchSettings.json:6` escucha en `http://127.0.0.1:5080` con entorno Development, donde se habilita Swagger.

Para compilar sin ejecutar migraciones ni tocar registros:

```powershell
dotnet build ./backend/BancoSangre.Api/BancoSangre.Api.csproj
```

Con la base ya preparada, para iniciar sin aplicar migraciones automáticamente:

```powershell
dotnet run --project ./backend/BancoSangre.Api/BancoSangre.Api.csproj --launch-profile http
```

`backend/ejecutar.ps1` es el lanzador existente: localiza el SDK de usuario y ejecuta `dotnet tool restore`, `dotnet ef database update` (17) y `dotnet run` (19). Por tanto, **ese script sí puede actualizar el esquema** si hay migraciones pendientes. Se conservó, pero no se ejecutó en esta revisión. `.config/dotnet-tools.json` fija dotnet-ef 10.0.13.

Para una demostración futura autorizada en Swagger:

1. Abre `http://127.0.0.1:5080/swagger` y consulta los bancos y uno por ID.
2. Obtén un Firebase ID Token vigente de una cuenta temporal del mismo proyecto. `backend/README.md`, sección “Probar con Swagger” (121), contiene el procedimiento existente para obtenerlo; no es otro login implementado en C#.
3. En Authorize pega únicamente el token. Swagger agrega el prefijo Bearer.
4. Ejecuta POST con banco válido y fecha futura. Anota el ID de tu cita temporal.
5. Ejecuta GET por ese ID y GET del listado. Comprueba la fila mediante SELECT en SQL.
6. Ejecuta PUT cambiando banco/fecha y vuelve a consultar.
7. Ejecuta DELETE únicamente para esa cita temporal y verifica que GET devuelve 404.
8. Sin token, comprueba 401; con otra cuenta temporal, comprueba que la cita ajena no puede leerse, modificarse ni eliminarse.

Consulta de solo lectura para comprobar asociaciones en SQL Server Management Studio:

```sql
USE BancoSangreAcademico;
SELECT c.Id, c.DonanteId, c.BancoSangreId, b.Nombre AS Banco, c.FechaHora
FROM dbo.Citas AS c
JOIN dbo.BancosSangre AS b ON b.Id = c.BancoSangreId
JOIN dbo.Donantes AS d ON d.Id = c.DonanteId
ORDER BY c.Id;
```

Este recorrido describe cómo demostrarlo después; **no se ejecutó CRUD ni se cambió la base de datos para preparar este material**.

## 9. Pruebas existentes y qué demuestran

| Archivo | Punto de entrada | Qué comprueba |
| --- | --- | --- |
| `backend/probar-api.ps1` | Bloque `try` (39); funciones `Comprobar` (14), `Peticion` (19), `Sql` (27), `NuevaCuenta` (32) | 29 comprobaciones reales de API, Firebase y SQL: CRUD, persistencia, fechas, bancos inválidos, duplicados, tokens e aislamiento entre dos usuarios. No son mocks. |
| `test/widget_test.dart` | `main` (62), casos `testWidgets` y `test` | 13 pruebas de Flutter. Usan `FakeRepository`; no prueban SQL ni una conexión real a C#. |
| `test/fake_repository.dart` | Clase `FakeRepository` (5) | Repositorio simulado para las pruebas de Flutter. No es un repositorio ni una capa extra del backend C#. |
| `integration_test/firebase_flow_test.dart` | `main` (28), caso `testWidgets` (30) | Prueba Android real con Firebase/Firestore: login, registro, perfil, donante y solicitud. No ejecuta CRUD de citas SQL. |
| `test_driver/integration_test.dart` | `main` | Driver de la prueba Android y guardado de capturas. |

`probar-api.ps1` requiere PowerShell 7, API encendida, SQL Server/sqlcmd y Firebase configurado. **Crea y elimina sus propios datos temporales y cuentas**, y guarda resultados. Su opción `CredencialesPath` puede conservar temporalmente cuentas para otras pruebas. No se ejecutó aquí porque esta tarea prohíbe modificar la base.

El resultado existente `backend/pruebas-api.json` registra 29 comprobaciones anteriores aprobadas. Se revisó como evidencia histórica, pero no se incluyó en el ZIP porque el paquete es de código, no de registros ni resultados. Algunas secciones de los README existentes también describen etapas anteriores; este mapa identifica el alcance actual y las 13 pruebas actuales de Flutter.

## 10. Comentarios y complejidad

Ya había comentarios en español sobre SQL Server, validación de Firebase, identidad del token, proyección a DTO, validación del banco, transacción de alta, modificación permitida, eliminación propia, relaciones, UID sensible a mayúsculas e índices únicos.

Se añadieron **12 comentarios breves**: cuatro en Program.cs, cuatro en CitasController.cs, uno en BancosSangreController.cs, dos en BancoSangreDbContext.cs y uno en CitasDtos.cs. Se precisó un comentario de Donante.cs para distinguir perfil en Firestore y contraseñas gestionadas por Firebase Authentication. No se cambió ninguna instrucción ejecutable.

El backend es apropiado para una práctica universitaria: un proyecto, dos Controllers con DbContext directo, tres entidades, DTOs en un solo archivo y cinco acciones de citas fáciles de localizar. No usa Clean Architecture, CQRS, MediatR, repositorios genéricos ni Unit of Work propio. No se detectaron clases manuales innecesarias. La parte más extensa es la validación JWT; responde a una necesidad real de seguridad. Los Designer y snapshot pueden parecer repetidos, pero son archivos generados que EF necesita conservar. La segunda migración es pequeña y cosmética; ya forma parte del historial, por lo que no se quitó ni combinó.

Para defenderlo, conviene saber reconocer `record`, constructores primarios, LINQ, expresiones lambda y consultas `IQueryable`: son recursos del lenguaje y de EF, no nuevas capas arquitectónicas.

## 11. Explicación oral de unos dos minutos

“El proyecto tiene una aplicación Flutter y un backend académico desarrollado en C# con ASP.NET Core Web API. Mantuvimos las pantallas existentes. Flutter utiliza Firebase Authentication para el acceso y Firestore para perfiles, donantes disponibles y solicitudes de sangre. Actualmente las citas del backend se demuestran por Swagger, porque retiramos las interfaces añadidas que no pertenecían al diseño del profesor.

La API REST recibe solicitudes HTTP. Un endpoint es una dirección y un método que permiten ejecutar una operación. Los Controllers reciben esas solicitudes, validan sus datos y utilizan Entity Framework Core para consultar y guardar en SQL Server. El DbContext representa el acceso a las tablas, y los Models representan sus entidades.

Tenemos tres tablas del negocio: BancosSangre, Donantes y Citas. Cada cita pertenece a un banco y a un donante mediante claves foráneas. El donante de SQL guarda únicamente su ID y el FirebaseUid; no duplicamos el perfil completo ni almacenamos contraseñas. Las migraciones describen cómo crear las tablas y sus restricciones.

Para operar sobre citas, la API exige un Firebase ID Token válido. Obtiene la identidad desde ese token y filtra las operaciones por propietario. Así, una cuenta no puede consultar ni modificar citas ajenas.

El CRUD permite crear, leer, modificar banco y fecha, y eliminar una cita propia. Antes de guardar comprueba que el banco exista y que la fecha sea futura. SaveChangesAsync confirma los cambios en SQL Server. Para demostrar la persistencia, podemos crear una cita temporal con Swagger, verla con una consulta SQL, modificarla y eliminarla. La estructura se mantiene pequeña: dos Controllers y un DbContext, sin capas adicionales innecesarias.”

## 12. Qué contiene el ZIP y qué se verificó ahora

`BancoSangre_Codigo_Para_Estudio.zip` conserva las rutas `backend/`, `lib/`, `test/`, `integration_test/` y `test_driver/`, junto con configuración segura, pubspec, reglas de Firestore y este mapa. Incluye todos los Dart de lib para seguir las referencias sin añadir pantallas. El README de entrada del ZIP explica sus límites.

Solo en la copia del ZIP se sustituye la API key pública de `lib/firebase_options.dart` por `CONFIGURAR_API_KEY_DE_FIREBASE`. Aunque es configuración de cliente y no una clave privada de administrador, se omite deliberadamente para compartir el material de estudio. La configuración funcional original no se modifica. Las claves privadas, tokens reales, archivos de servicio y credenciales no se incluyen. Las contraseñas literales de los tests de widgets son ejemplos ficticios para validar formularios.

No incluye bin/obj/build, APK, cachés, dependencias descargadas, registros de base de datos, resultados históricos, capturas, imágenes/fuentes ni carpetas nativas. **Es un paquete de estudio de código, no una copia completa lista para ejecutar Flutter**. Para ejecutar Flutter utiliza el proyecto original; para pruebas reales de Firebase también hace falta una configuración propia válida. El proyecto C# sí conserva sus archivos de proyecto, configuración y migraciones.

Validación realizada ahora: compilación del backend con .NET SDK 10.0.402, **0 errores y 0 advertencias**. Se compiló a una carpeta temporal para no sustituir los binarios de una API en ejecución. Los 13 archivos C# son idénticos a su respaldo al excluir las líneas de comentarios; las migraciones no cambiaron. No se ejecutaron el lanzador con migraciones ni las pruebas que modifican datos. No se tocó SQL Server, no se borraron registros, no se modificó Flutter y no se hizo commit ni push.
