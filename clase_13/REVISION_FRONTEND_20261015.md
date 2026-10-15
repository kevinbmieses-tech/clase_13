# Revisión del frontend original - 15/10/2026

## Referencia comprobada

Se utilizó el código entregado en `C:/Users/geral/Downloads/OneDrive_1_1-10-2026/Archive` y se contrastó con `C:/Users/geral/Downloads/OneDrive_2026-10-15/Proyecto Donacion Sangre/Archive.zip`. Home, menú y formulario de solicitud coinciden en ambos originales, ignorando espacios de formato. No se modificó ninguna de esas copias.

El respaldo `clase_13_antes_backend_20261015` ya contenía adaptaciones de la integración anterior con Firebase; por eso no bastaba para recuperar la apariencia del profesor. El proyecto principal no tiene historial Git disponible.

## Pantallas y procedencia

Las rutas de archivos siguientes son relativas a `lib/src/screens/views`.

| Pantalla/archivo original | Situación actual |
| --- | --- |
| `onboarding/splash_screen.dart` | Conservado; no modificado en esta revisión. |
| `onboarding/onboarding_screen.dart` | Conservado con la adaptación anterior; no modificado. |
| `auth/login_screen.dart` | Conservado con Firebase; no modificado. |
| `auth/register_screen.dart` | Conservado con Firebase; no modificado. |
| `auth/forgot_password_screen.dart` | Conservado con recuperación por correo de Firebase; no modificado. |
| `auth/recovery_screen.dart` | Existía en el ZIP; ya estaba ausente antes del backend y antes de esta revisión. No se borró ahora. |
| `auth/otp_recovery_screen.dart` | Existía en el ZIP; ya estaba ausente antes del backend y antes de esta revisión. No se borró ahora. |
| `home/screens/home_screen.dart` | Restaurados el AppBar, las tres tarjetas y su distribución original. |
| `profile/screens/profile_screen.dart` | Conservado con datos reales; no modificado. |
| `edit_profile/screens/edit_profile_screen.dart` | El archivo del profesor estaba vacío. Su implementación funcional anterior se conserva. |
| `donor_registration/screens/donor_registration_screen.dart` | Conservado con persistencia de donantes; no modificado. |
| `find_donor/screens/find_donor_screen.dart` | Es el formulario original “Request for Blood Donor”; se conserva con sus validaciones y Firestore. |
| `all_requests/screens/all_request_screen.dart` | Conservado con filtros y datos reales; no modificado directamente. Utiliza la tarjeta del feed restaurada. |
| `all_request_details/screens/request_details_screen.dart` | Conservado con los detalles reales y cierre de solicitudes; no modificado. |

La pantalla `find_donor/screens/donor_search_screen.dart` no está en los originales: se añadió en la integración anterior con Firebase, antes del backend. Se conserva porque el botón “Find Donors” del formulario actual la utiliza para consultar los donantes disponibles en Firestore. Se retiraron sus accesos directos añadidos al Home y al menú, recuperando los destinos originales de esos accesos. No se creó ninguna pantalla nueva.

Las tres pantallas de bancos/citas añadidas durante el backend ya estaban eliminadas al iniciar esta revisión. Se comprobó que no hay imports ni rutas a ellas en el frontend actual.

## Request Blood y navegación

“Request for Blood Donor” **sí existía** en el código del profesor: clase `FindDonorScreen`, archivo `find_donor/screens/find_donor_screen.dart`, ruta `/find-donor`. Originalmente se abría desde la tarjeta “Find a donor” y la opción “Find Donors” del menú. Ambos destinos se restauraron.

La cuarta tarjeta “Request blood” y el acceso separado del mismo nombre en el menú eran añadidos de la integración anterior. Se retiraron, pero no se eliminó el formulario ni la persistencia de solicitudes. El diseño base del formulario existía; su lógica, validaciones y adaptación visual actual fueron modificadas en la integración con Firebase. No se revirtió ese formulario en esta corrección. Se conserva “Cause”, solicitado anteriormente por el usuario.

Las rutas originales de login, registro, donantes, solicitudes, detalles, perfil y búsqueda/formulario se conservan. El alias interno actual de Home continúa siendo `/home` (el ZIP usaba `/home-screen`) para mantener la compatibilidad de la aplicación integrada. Recuperación y edición de perfil conservan sus rutas funcionales `/forgot-password` y `/edit-profile`, implementadas anteriormente. Los detalles reciben el ID de la solicitud al navegar.

## Home y menú restaurados

Home contiene solamente “Find a donor”, “Requests” e “I want to donate”: las dos primeras tarjetas en la primera fila y la tercera centrada debajo, seguidas de “Request Feed”, “See all” y solicitudes reales. Se reutilizó `CustomHomeContainer` sin modificarlo: mismos tamaños relativos, rojo `#A30000`, bordes, sombras, tipografía e imágenes.

El Home original comprobado no incluye una sección separada de donantes disponibles. No se inventó esa sección. La consulta existente de donantes sigue en la búsqueda citada arriba.

El menú vuelve a estas cinco opciones, en este orden y con sus iconos originales:

1. Donor Registration.
2. Find Donors.
3. Blood Requests.
4. Profile.
5. Logout.

Se retiraron “Home” y “Request blood”. Los rótulos añadidos “I want to donate” y “Requests” del menú volvieron a “Donor Registration” y “Blood Requests”. “Find Donors” recuperó su posición y destino originales. Se restauraron el fondo rojo translúcido, cierre, avatar y pie “Version 1.0.0”. El nombre mostrado procede del perfil real, en lugar del ejemplo fijo “Jorge Perez”. Logout conserva el cierre de sesión y limpieza de navegación de la integración actual.

El feed recuperó su contenedor, sombra, distintivo del grupo y botón originales, además de `request_location.png` y `request_date.png`. Conserva los registros de Firestore y el ID correcto en “Details”; la fecha de publicación real ocupa el lugar del texto ficticio “2 minute ago”.

Se compararon por SHA-256 los **24 recursos** del paquete original (imágenes, iconos y fuentes): todos existen en el proyecto actual y coinciden. No se sustituyeron ni generaron recursos.

## Archivos modificados en esta revisión

| Archivo | Cambio |
| --- | --- |
| `lib/src/screens/views/home/screens/home_screen.dart` | Recupera la composición original del Home y sus tres destinos. |
| `lib/src/screens/views/components/widgets/home_drawer.dart` | Recupera las cinco opciones, orden y presentación originales; conserva Firebase. |
| `lib/src/screens/views/components/widgets/custom_drawer_item.dart` | Activa la navegación del widget original y permite el cierre de sesión existente. |
| `lib/src/screens/views/home/widgets/request_feed_item.dart` | Recupera el diseño original con datos reales y navegación por ID. |
| `lib/src/screens/views/home/widgets/requests_feed.dart` | Recupera la separación original entre tarjetas sin cambiar consultas ni filtros. |
| `test/widget_test.dart` | Ajusta la prueba al icono original del menú, usa tamaño de teléfono y Poppins, y verifica las tres tarjetas y todos los destinos del menú. Conserva las pruebas existentes. |
| `integration_test/firebase_flow_test.dart` | Usa “Find a donor” para abrir el formulario original y captura Home/menú con Firebase real. |

Este informe y las capturas `screenshots/home-restaurado.png` y `screenshots/menu-restaurado.png` son los nuevos artefactos de revisión. La prueba también actualizó `screenshots/android-request-details.png`.

## Comprobaciones ejecutadas

- `dart format`: los siete archivos Dart modificados, sin pendientes.
- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub`: **13 pruebas aprobadas**. Incluyen las tres tarjetas, las cinco opciones y navegación a los cuatro destinos del menú, logout, registro, recuperación, validación, filtros, detalles y edición de perfil. Estas pruebas usan el repositorio de pruebas, no Firebase real.
- `flutter drive` en `emulator-5554`, con `integration_test/firebase_flow_test.dart`: **aprobado contra Firebase Authentication y Firestore reales**. Login, perfil de donante, publicación y lectura de solicitud, cierre de solicitud, logout, registro de una cuenta nueva y lectura de su perfil. También se verificaron y capturaron las cinco opciones del menú.
- Se confirmó por la API real de Firestore que la solicitud temporal pertenecía a la cuenta de prueba y estaba cerrada. Se eliminaron exclusivamente las cuentas/perfiles temporales; la solicitud sintética queda cerrada porque las reglas actuales no permiten borrar solicitudes. No se cambiaron las reglas.
- `flutter build apk --debug --no-pub`: APK normal compilado e instalado en el emulador después de la prueba, sin credenciales de prueba incorporadas. Se abrió la aplicación normal y se comprobó el paso de onboarding al login, con registro y recuperación visibles.
- Capturas nuevas revisadas visualmente: tres tarjetas sin desbordamientos y menú con las cinco opciones originales.
- **24 archivos del backend** (código, configuración, migraciones, scripts y documentación, excluyendo productos de compilación) comparados con sus huellas previas: **cero diferencias**. No se ejecutaron operaciones en SQL Server ni se cambiaron sus registros. No se repitieron las pruebas de C# en esta revisión del frontend.

Los intentos iniciales de pruebas mostraron que el tamaño de escritorio del entorno de pruebas no coincidía con el tamaño usado por MediaQuery. Se corrigió la configuración del test para usar medidas reales de teléfono y Poppins, sin cambiar el widget original ni ignorar errores.

## Límites de la comparación

No se adjuntó una nueva imagen independiente de referencia en esta solicitud. La restauración se contrastó con el código y recursos originales comprobados, no con una comparación de píxeles de esa imagen pendiente. Los textos y datos reales difieren de los ejemplos estáticos del profesor. Otras pantallas conservan sus adaptaciones funcionales previas de Firebase; no se afirma que todo el frontend sea idéntico al ZIP.

El respaldo completo anterior a esta corrección está fuera del proyecto: `C:/Users/geral/OneDrive/Documentos/ChatGPT/banco_antes_restaurar_diseno_20261015_1792082277`. No se borraron archivos Dart en esta revisión. No se hizo commit ni push.
