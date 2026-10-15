# Integración realizada el 1 de octubre de 2026

## Base y respaldo

Base utilizada: C:/Users/geral/OneDrive - INTEC/INTEC/Trimestre 13/mobile/clase_13/clase_13.

Pantallas recibidas: C:/Users/geral/Downloads/OneDrive_1_1-10-2026.

Respaldo anterior a los cambios: C:/Users/geral/OneDrive/Documentos/ChatGPT/clase_13_respaldo_20261001. Incluye lib, assets, android, pubspec.yaml, pubspec.lock, README y test. La carpeta recibida permanece intacta.

## Qué se juntó y qué se reemplazó

- Se incorporaron constants, general, repositories, screens y services del archivo recibido dentro de lib/src.
- Se corrigieron los imports del paquete proyecto_laboratorio_intec al nombre existente clase_13.
- Se normalizaron las carpetas duplicadas de assets y se incluyeron las imágenes, iconos y fuentes Poppins.
- Se reemplazó el arranque y la navegación provisional por una sesión real de Firebase que limpia las pantallas protegidas al cerrar sesión.
- Se reemplazaron AuthRepository y AuthServiceFirebase incompletos por BloodRepository y FirebaseBloodRepository, con datos tipados y guardado real.
- Se sustituyeron las pantallas de recuperación/OTP sin un servicio que enviara códigos por recuperación mediante el correo de Firebase.
- Se conectaron las pantallas de registro, login, perfil, edición, donantes, solicitudes y detalles. Los botones utilizan los datos seleccionados en lugar de ejemplos fijos.
- Se agregó búsqueda de donantes por grupo declarado y ubicación, y filtros de solicitudes, incluyendo las propias.
- Se agregaron validación, estados de carga, manejo de errores y reintentos. Cancelar una selección de fecha o de foto ya no rompe el formulario.
- Se configuró Firebase para Android y web y se publicaron reglas que limitan las escrituras al dueño de cada dato.
- El manifiesto de Android incluye Internet y el nombre visible Donar Sangre.

## Resultado verificado

- Análisis de Flutter sin problemas.
- 12 pruebas unitarias y de pantallas aprobadas.
- Prueba en Android con Firebase real: login, perfil de donante, solicitud, cierre de solicitud, logout y registro de una nueva cuenta con perfil privado.
- Comprobaciones contra la base real: lectura autenticada permitida; lectura sin sesión y lectura de un perfil ajeno rechazadas.
- Captura de Details en Android y captura de la solicitud guardada en la consola de Firebase.
- APK de depuración disponible en build/app/outputs/flutter-apk/app-debug.apk.

## Alcance pendiente de teléfono físico

Comprobar cámara, galería, apertura de llamadas/SMS y recepción del correo de recuperación. La app abre las aplicaciones correspondientes del dispositivo; no realiza llamadas ni envía SMS por sí sola. iOS y escritorio no se configuraron con Firebase.

