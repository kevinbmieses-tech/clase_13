# Preparar SQL Server + Firebase en macOS para clase_13

## Qué implementa el repositorio

- Flutter conserva el inicio de sesión, perfiles, donantes y solicitudes mediante Firebase Authentication y Cloud Firestore.
- La API `BancoSangre.Api` usa SQL Server/EF Core para bancos de sangre, donantes (solo FirebaseUid) y citas.
- El `BancoSangreDbContext` y las migraciones existentes son la fuente de verdad para las tablas, claves foráneas, índices y datos iniciales. **No crear tablas manualmente en paralelo a EF.**
- Flutter actualmente **no consume los endpoints de citas**; para demostrarlas usa Swagger.
- El ID de proyecto Firebase que figura en `lib/firebase_options.dart` es `donar-sangre-intec`. El backend valida tokens de ese proyecto mediante `Firebase:ProjectId`.

## Requisitos

1. Instalar y abrir Docker Desktop para Mac. Comprobar: `docker --version` y `docker info`.
2. Instalar **SDK .NET 10** (el `.csproj` tiene `net10.0` y EF Core 10). Comprobar `dotnet --list-sdks`.
3. Si la Mac tiene Apple Silicon (M1/M2/M3/M4...), recordar que la imagen SQL Server para Linux es **amd64**; bajo emulación en ARM64 no está oficialmente soportada. Si no arranca o es inestable, ejecutar el contenedor en un host x86-64 remoto y cambiar la cadena de conexión. No usar esta configuración para producción.

## SQL Server local

Desde la raíz que contiene `clase_13/`:

```bash
cd clase_13/backend
cp .env.example .env
```

Editar `backend/.env` y reemplazar `REEMPLAZAR_CON_CONTRASENA_FUERTE` por una contraseña local robusta de SA (al menos 8 caracteres; usar mayúsculas, minúsculas, números y símbolos compatibles con el archivo). **No subir este archivo a GitHub ni compartir su contenido.**

```bash
docker compose up -d
docker compose ps
docker compose logs --tail=80 sqlserver
```

Para iniciar la API y crear/actualizar tablas con las migraciones de EF, desde la raíz:

```bash
bash clase_13/backend/iniciar-macos.sh
```

El script establece la cadena de conexión local solo en el proceso, restaura `dotnet-ef` 10 y ejecuta `dotnet ef database update`. No borra datos ni reconstruye migraciones. La base queda en el volumen Docker `sqlserver_data` del proyecto Compose.

Si el contenedor aún no está listo, espera y repite el comando. Si SQL Server se cierra con errores de arquitectura o emulación, utiliza un SQL Server x86-64 remoto en vez de seguir forzando el contenedor ARM64.

**No uses `docker compose down -v`**, porque elimina el volumen y los datos.

API (con la terminal del script abierta): http://127.0.0.1:5080/swagger

Verificación de conexión:

```bash
curl -i http://127.0.0.1:5080/api/bancos-sangre
```

Deberías obtener un JSON con dos bancos de práctica. Las tablas SQL esperadas son `BancosSangre`, `Donantes`, `Citas` y `__EFMigrationsHistory`.

Para cambiar la conexión sin editar código, define `ConnectionStrings__BancoSangre` y `Firebase__ProjectId` en el entorno antes de `dotnet run`. La cadena de Docker **no es** la antigua de Windows `.\\SQLEXPRESS;Trusted_Connection=True`.

## Firebase

1. Abre https://console.firebase.google.com/ y selecciona el proyecto **donar-sangre-intec**. Debes tener permisos para administrarlo. Si no es tuyo, pide acceso o crea tu propio proyecto y actualiza conjuntamente la configuración del frontend y el ID del backend.
2. En **Authentication > Sign-in method**, activa **Email/Password**. `FirebaseBloodRepository` usa `signInWithEmailAndPassword`, `createUserWithEmailAndPassword` y `sendPasswordResetEmail`.
3. En **Firestore Database**, crea la base de datos en modo de producción si aún no existe (elige la región que corresponda a tu proyecto). No uses reglas de prueba abiertas.
4. Instala el CLI de Firebase (requiere Node.js):
   `npm install -g firebase-tools`
5. Desde `clase_13/`, ejecuta:
   ```bash
   firebase login
   firebase use donar-sangre-intec
   firebase deploy --only firestore:rules
   ```
   El archivo `firebase.json` apunta a `firestore.rules`. El despliegue cambia las reglas del proyecto real: revisa los permisos antes de confirmar.
6. Prueba desde Flutter: registro, login, edición de perfil, listado de donantes y publicación/cierre de solicitudes. Se usan colecciones `users`, `donors` y `requests`, declaradas en `firebase_blood_repository.dart`.

### Plataformas Firebase

- `lib/firebase_options.dart` tiene configuraciones para **Android y web**, no para ejecutar Flutter como aplicación macOS o iOS.
- El `applicationId` Android actual es `com.example.clase_13`. Comprueba que coincida con la aplicación Android registrada en Firebase.
- Si tienes un proyecto Firebase diferente o quieres iOS/macOS, instala el CLI de FlutterFire y usa `flutterfire configure --project=<TU_PROYECTO>` **revisando** previamente qué aplicaciones/plataformas va a actualizar. No reemplaces credenciales a ciegas.
- La configuración cliente de Firebase (`apiKey`, projectId y appId) no es una cuenta de servicio. **Nunca publiques** JSON de cuentas de servicio, claves privadas ni contraseñas de SQL Server.
- El backend **no requiere** un Admin SDK privado para validar los ID Tokens: utiliza el emisor y las claves públicas de Google.

## Limitaciones y siguientes tareas

La conexión Firebase y la definición de SQL están preparadas en código; crear el contenedor, aplicar las migraciones y desplegar reglas exige ejecutar los comandos con acceso a tu Mac y a Firebase. No se han creado recursos externos desde este repositorio.

Las pantallas Flutter originales no incorporan UI de citas SQL. Si quieres agendar citas desde la app, hay que desarrollar un cliente HTTP con Firebase ID Token y la UI correspondiente, sin confundir citas con solicitudes Firestore.
