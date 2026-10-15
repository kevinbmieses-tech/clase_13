# Donar Sangre — INTEC

El nuevo backend académico de bancos y citas está en [backend/README.md](backend/README.md).
La API ya inicia en Windows, las migraciones están aplicadas y el CRUD se comprobó contra SQL Server y Firebase reales.

Se conserva el alcance visual original: se retiraron las tres pantallas añadidas de bancos y citas.
Las pantallas del profesor mantienen Firebase Authentication y Firestore. Como no incluyen gestión
de citas, ese CRUD se demuestra directamente con Swagger y SQL Server; ninguna pantalla original
se reutiliza con un significado diferente. La guía del backend explica cómo repetir la demostración.

Proyecto clase_13 integrado con las pantallas de OneDrive_1_1-10-2026. Se conserva el nombre del paquete y la estructura nativa de Android; la app ahora utiliza Firebase real.

## Abrir y ejecutar

Abrir esta carpeta, la que contiene pubspec.yaml, en Android Studio o VS Code. Con Flutter instalado:

```sh
flutter pub get
flutter run -d <dispositivo-android>
```

Crear una cuenta desde Register. Para aparecer en Find Donors, completar I want to donate y mantener Available as a donor activado. Request blood publica una solicitud; Requests permite filtrarla por grupo, ubicación o autor. Su autor puede cerrarla desde Details.

## Firebase

[Consola del proyecto](https://console.firebase.google.com/project/donar-sangre-intec/overview)

- Proyecto: donar-sangre-intec, plan Spark.
- Authentication: correo y contraseña habilitados.
- Cloud Firestore: base (default), ubicación nam5.
- users: perfil privado de cada cuenta.
- donors: datos compartidos voluntariamente por donantes disponibles, sin el correo de la cuenta.
- requests: solicitudes consultables por usuarios autenticados; solo su autor puede cerrarlas.
- firestore.rules contiene las reglas publicadas; firebase.json y .firebaserc permiten volver a desplegarlas con una sesión propia de Firebase CLI.
- lib/firebase_options.dart contiene la configuración pública de Android y web. No hacen falta credenciales de administrador ni claves privadas para ejecutar la app.
- La foto de perfil se reduce y se guarda en el perfil; esta versión no necesita Firebase Storage ni un plan de pago.

Android y web están configurados. iOS y escritorio requieren registrar sus aplicaciones en Firebase antes de utilizarlos.

## Verificación

```sh
flutter analyze
flutter test
flutter build apk --debug
```

La prueba de integración en integration_test/firebase_flow_test.dart usa Firebase real y un emulador Android. Requiere una cuenta temporal en TEST_EMAIL y TEST_PASSWORD. Publica una solicitud sintética, la cierra y deja el donante fuera del listado público. También prueba el registro de una cuenta nueva y limpia esa cuenta temporal al terminar.

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/firebase_flow_test.dart -d <emulador> --dart-define=TEST_EMAIL=<correo-de-prueba> --dart-define=TEST_PASSWORD=<contraseña-de-prueba>
```

No usar datos de personas reales para estas pruebas. Las capturas verificadas están en screenshots/. Las solicitudes de prueba permanecen cerradas y se identifican como Integration Test Patient.

Cámara, galería y botones Call/Message están conectados a las aplicaciones del dispositivo; falta comprobarlos en un teléfono físico. La recuperación usa el enlace de correo de Firebase; el envío a una bandeja real no formó parte de la prueba automática.

Ver INTEGRACION.md para los reemplazos y el respaldo.

