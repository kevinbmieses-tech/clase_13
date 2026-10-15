# Revisión final y demostración — Banco de Sangre

> Documento histórico de la versión anterior, que incluía las tres interfaces de citas añadidas.
> Esas interfaces ya fueron retiradas por indicación del usuario. El alcance actual, las pruebas
> conservadas y la demostración mediante Swagger y SQL están en [backend/README.md](../backend/README.md).

15 de octubre de 2026. Proyecto existente: `clase_13/clase_13`.

## FUNCIONAMIENTO

**El CRUD se comprobó desde Flutter en Android Emulator, con Firebase Authentication,
la API C# y SQL Server Express reales. No se utilizaron mocks para estas comprobaciones.**

- SQL Express está iniciado. Existe `BancoSangreAcademico` con `BancosSangre`, `Donantes`
  y `Citas`; `__EFMigrationsHistory` es únicamente la tabla técnica de EF Core.
- La API se reinició y arrancó correctamente en `http://127.0.0.1:5080`.
  Swagger y su documento OpenAPI respondieron correctamente.
- Android accedió al servidor mediante `http://10.0.2.2:5080`.
- Se inició sesión desde el formulario real y se llegó al Home.
- El catálogo API coincidió campo por campo con SQL. Flutter lo consulta por HTTP;
  no contiene una lista fija de bancos. Los dos bancos son datos ficticios de práctica
  insertados mediante la migración, y la pantalla lo indica.
- Se repitieron las **29 comprobaciones REST**: CRUD, fechas, banco inexistente,
  duplicados, ausencia de token y aislamiento entre dos usuarios reales de Firebase.

### Filas comprobadas durante la prueba

La fecha de SQL está en UTC; la app mostró las 10:15 AM del emulador, equivalentes a 14:15 UTC.

| Paso | CitaId | DonanteId | BancoSangreId | FechaHora SQL | Resultado |
|---|---:|---:|---:|---|---|
| Crear desde Flutter | 11 | 4 | 1 | 2026-10-17T14:15:00Z | Una fila; visible en Mis citas. |
| Editar desde Flutter | 11 | 4 | 2 | 2026-10-18T14:15:00Z | Mismo ID; banco y fecha actualizados. |
| Eliminar desde Flutter | 11 | — | — | — | Cero filas; desapareció de Mis citas. |
| Crear para persistencia | 12 | 4 | 1 | 2026-10-20T14:15:00Z | Una fila. |
| Con API y Flutter cerrados | 12 | 4 | 1 | 2026-10-20T14:15:00Z | La fila permaneció en SQL. |
| Tras reiniciar API y reabrir APK normal | 12 | 4 | 1 | 2026-10-20T14:15:00Z | HTTP 200 y visible en Mis citas. |
| Eliminar desde APK normal | 12 | — | — | — | Cero filas; lista vacía. |

En la reapertura del APK normal se confirmó el cierre completo del proceso Android:
pasó del PID 11240 al 11825, sin reinstalar entre ambos. Firebase restauró la sesión y
Home apareció sin volver a introducir credenciales. La API pasó del PID 36160 al 24808.

La prueba automatizada inicial de reapertura no llegó a Home y **no se cuenta como aprobada**.
La comprobación válida de reapertura se hizo posteriormente con el APK normal instalado,
operando sus controles reales y consultando SQL. Los primeros ajustes del recolector SQL
afectaron únicamente al script temporal de revisión; el recorrido CRUD se repitió completo.

### Evidencias para abrir

| Evidencia | Archivo |
|---|---|
| Login vacío, sin credenciales | [00-login-sin-credenciales.png](00-login-sin-credenciales.png) |
| App abierta y autenticada | [01-home-autenticado.png](01-home-autenticado.png) |
| Bancos obtenidos por HTTP | [02-bancos-desde-api.png](02-bancos-desde-api.png) |
| Formulario | [03-formulario.png](03-formulario.png), [04-formulario-completo.png](04-formulario-completo.png) |
| Cita creada, editada y eliminada | [05-cita-creada.png](05-cita-creada.png), [06-cita-modificada.png](06-cita-modificada.png), [07-cita-eliminada.png](07-cita-eliminada.png) |
| Filas SQL de cada operación | [02-sql-interfaz.json](02-sql-interfaz.json) |
| La misma cita con los procesos cerrados | [03-sql-api-y-flutter-cerrados.txt](03-sql-api-y-flutter-cerrados.txt) |
| Reapertura del APK normal y sesión restaurada | [10-cita-tras-reabrir-apk-normal.png](10-cita-tras-reabrir-apk-normal.png), [04-reapertura-apk-normal.json](04-reapertura-apk-normal.json) |
| SQL después de reabrir | [04-sql-tras-reabrir-apk.txt](04-sql-tras-reabrir-apk.txt) |
| Limpieza de la cita de persistencia | [11-persistencia-eliminada-apk-normal.png](11-persistencia-eliminada-apk-normal.png), [05-limpieza-cita-persistencia.json](05-limpieza-cita-persistencia.json) |
| Seguridad y validaciones: 29 comprobaciones | [01-api-seguridad.json](01-api-seguridad.json) |
| SQL y API devuelven el mismo catálogo | [00-catalogo-sql-api.json](00-catalogo-sql-api.json) |

Se eliminaron solamente las citas, los vínculos SQL y las dos cuentas temporales creadas
para esta revisión. La base empezó y terminó con cero citas y conserva sus dos bancos.
No se borraron registros anteriores ni se cambiaron reglas de Firebase o de Windows Firewall.
Las evidencias no contienen contraseñas ni ID tokens. Los logs compartidos se limitaron
a resultados de comprobación, sin las credenciales temporales.

**Sin comprobar en esta revisión:** teléfono físico, iOS, citas en Flutter web y despliegue HTTPS/release.
No se repitieron aquí todas las funciones antiguas de Firestore: el Home leyó su feed real,
pero registro de perfil y solicitudes se habían probado en la etapa anterior.
Los tests locales con repositorios simulados y MockClient no se usan como evidencia del CRUD real.

## CALIDAD DEL CÓDIGO

El proyecto `backend/BancoSangre.Api` contiene **16 archivos**, excluyendo `bin` y `obj`:

| Grupo | Cantidad | Utilidad |
|---|---:|---|
| C# escrito a mano | 8 | Program, dos Controllers, tres Models, DbContext y un archivo de DTOs. |
| C# generado por EF Core | 3 | Migración inicial, metadatos de esa migración y snapshot del modelo. |
| Configuración | 5 | csproj, dos appsettings, launchSettings y manifiesto de dotnet-ef. |

En toda la carpeta `backend` hay **22 archivos**: los 16 anteriores, dos scripts,
un README y tres resultados JSON. Esos seis archivos auxiliares no son capas de la API.
La lista individual y su función están en [backend/README.md](../backend/README.md).

La estructura es adecuada para la práctica: dos Controllers utilizan el DbContext directamente;
no hay repositorios personalizados, Unit of Work, MediatR, CQRS ni proyectos adicionales.
El Controller de citas tiene 102 líneas y el DbContext 50, incluyendo comentarios y espacios.
Las consultas filtran por el UID validado y EF Core genera SQL parametrizado; `SaveChangesAsync`
persiste los cambios. Los DTOs validan la entrada y evitan devolver la identidad privada del donante.

Los 16 archivos tienen una función justificada para esta configuración. Los tres generados por EF
no requieren explicación línea por línea en la defensa. No encontré clases de negocio innecesarias.
Los helpers `MisCitas` y `Respuesta` evitan repetir el filtro del propietario y la forma de respuesta.
Las validaciones en Flutter y en la API cumplen responsabilidades distintas y deben conservarse.

### Archivos que puedes enseñar y comentarios en español

| Tema | Archivo y punto de entrada |
|---|---|
| Configurar SQL Server | [Program.cs:11](../backend/BancoSangre.Api/Program.cs#L11); cadena local en appsettings.Development.json. |
| Modelos | Models/BancoSangre.cs, Models/Donante.cs y Models/Cita.cs. |
| Tablas, relaciones e índices | [BancoSangreDbContext.cs:28](../backend/BancoSangre.Api/Data/BancoSangreDbContext.cs#L28). |
| Validar Firebase | [Program.cs:20](../backend/BancoSangre.Api/Program.cs#L20): claves públicas, firma RS256, emisor, audiencia y caducidad. |
| Obtener usuario autenticado | [CitasController.cs:17](../backend/BancoSangre.Api/Controllers/CitasController.cs#L17): claim sub del token validado. |
| Consultar citas propias | CitasController.cs:20, Listar:38 y Obtener:42. |
| Crear y guardar | CitasController.cs:50, con comentario de guardado en SQL:61. |
| Actualizar | CitasController.cs:73 y comentario:79. |
| Eliminar | CitasController.cs:90 y comentario:94. |
| Consultar bancos | BancosSangreController.cs:13 y comentario SQL:15. |
| Flutter llama a C# | [banco_sangre_api.dart:39](../lib/src/services/banco_sangre_api.dart#L39): ID token; línea 66: petición HTTP. |

Los comentarios existentes cubren los puntos importantes. No detecté un comentario imprescindible
faltante ni añadí comentarios redundantes durante esta revisión.

**Oportunidades identificadas, sin aplicar cambios:**

- Unificar en el futuro el límite de fechas: Flutter permite elegir hasta dos años, mientras la API
  solo exige fecha futura. Una cita más lejana creada por otro cliente queda fuera del rango del selector
  al editarla. Es una observación del código; ese caso extremo no se probó en ejecución.
- Los resultados de pruebas pueden mantenerse agrupados como evidencias; no hace falta integrarlos
  en el código de la API. No conviene añadir capas para reducir o reorganizar estos Controllers.

La compilación C# terminó con **0 errores y 0 advertencias**, Flutter analyze no encontró incidencias
y el APK normal se compiló e instaló. [Integridad de fuentes](06-integridad-fuentes.json):
85 archivos comprobados sin modificaciones. En esta revisión no se añadieron funcionalidades,
no se cambió el diseño, no se hizo refactor, commit ni push.

## DEMOSTRACIÓN — aproximadamente tres minutos

### Preparar antes de comenzar

1. Mantén SQL Express iniciado. Desde la carpeta raíz del proyecto ejecuta
   `./backend/ejecutar.ps1` si la API no está encendida. Swagger está en
   [http://127.0.0.1:5080/swagger](http://127.0.0.1:5080/swagger).
2. Abre Android Emulator y la app **Donar Sangre**; el APK normal ya está instalado.
   Usa tu cuenta propia de Firebase. Las cuentas temporales de esta revisión se eliminaron.
   Si necesitas registrarte, hazlo antes de la demostración desde Register Here.
3. Abre SQL Server Management Studio: servidor `.\SQLEXPRESS`, autenticación de Windows.
   Si pide confiar en el certificado, se trata del certificado local ya utilizado para la práctica.
   Expande Databases → BancoSangreAcademico → Tables para ver las tablas.
4. Abre [demostracion.sql](demostracion.sql) en New Query. Su consulta con JOIN es la que
   debes ejecutar después de cada operación. No borres tablas ni uses DELETE sin filtrar.

### Recorrido frente al profesor

| Tiempo | Qué abrir y dónde hacer clic | Qué explicar |
|---|---|---|
| 0:00–0:25 | Si aparece la introducción, Skip. En Login introduce tu correo/contraseña y pulsa LOGIN. | Firebase Authentication realiza el acceso. No muestres ni leas la contraseña. |
| 0:25–0:45 | En Home, botón Bancos de sangre, debajo de las cuatro tarjetas principales. | La app pide el catálogo a C# y C# consulta SQL Server. Son bancos ficticios de práctica. |
| 0:45–1:15 | Pulsa Banco de práctica — Santo Domingo. Fecha: elige mañana o una fecha posterior. Hora: selecciona una hora. Agendar cita. | Flutter envía banco y fecha en JSON junto con el ID token. No envía un dueño elegido libremente. |
| 1:15–1:40 | Se abre Mis citas. Cambia a SSMS y ejecuta el SELECT con JOIN de demostracion.sql. | Señala el nuevo CitaId, DonanteId, BancoSangreId y FechaHora. Los IDs serán nuevos, no 11/12. |
| 1:40–2:10 | Vuelve a Flutter. Editar → cambia fecha o banco → Guardar cambios. Ejecuta otra vez el SELECT. | Es el mismo ID y cambió la información persistida. |
| 2:10–2:35 | Pulsa atrás para Home y vuelve a Mis citas, o usa actualizar. Luego Eliminar → Eliminar. Repite el SELECT. | La consulta recupera datos del servidor; el borrado desaparece de la app y de SQL. Elimina solo tu cita de demostración. |
| 2:35–3:00 | Muestra Program.cs, CitasController.cs y BancoSangreDbContext.cs si pregunta. | Resume el recorrido y las relaciones. |

Si quieres mostrar persistencia en lugar del borrado, conserva esa cita, cierra completamente
la app, vuelve a abrir Donar Sangre y entra en Mis citas. Puedes reiniciar la API antes de volver a
consultar. Después elimina únicamente tu cita de demostración.

Frase para cerrar: «Flutter es la interfaz. Firebase comprueba quién inició sesión. La API REST de
C# recibe las solicitudes HTTP y valida los datos. Sus Controllers usan Entity Framework Core y
el DbContext para leer y guardar en SQL Server. Citas tiene claves foráneas hacia un banco y un
donante, cuyo FirebaseUid procede del token validado. Cada usuario solo puede gestionar sus citas.
Lo demostramos comparando los cambios de la aplicación con los registros reales de SQL Server».
