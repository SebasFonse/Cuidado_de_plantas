# Plantacert AI – Frontend Flutter (Grupo 5)

Interfaz gráfica de Plantacert AI conectada al backend Quarkus de este mismo repositorio.

## Historias implementadas

| HU | Pantalla |
|----|----------|
| RQ1-HU01 | Registro de usuario, con enlace desde el inicio de sesión |
| RQ4-HU01 | Agregar planta y catálogo "Mis plantas" |

> El inicio de sesión real es RQ-02. Mientras tanto hay un **acceso temporal por ID de usuario** en la pantalla de login.

## Estructura

```
lib/
├── main.dart
├── app/        tema (verde #2E7D32) y MaterialApp
├── config/     URL del backend
├── core/       sesión, validadores y manejo de errores de la API
├── auth/       login y registro (RQ1-HU01)
├── inicio/     pantalla principal
└── plantas/    catálogo y agregar planta (RQ4-HU01)
```

## Ejecutar

1. Primera vez, dentro de `frontend/`: generar las carpetas de plataforma (no se suben a GitHub)
   ```
   flutter create --platforms=web,windows,android .
   flutter pub get
   ```
2. Encender el backend en la raíz del repo: `./mvnw quarkus:dev`
3. Ejecutar el frontend en Chrome:
   ```
   flutter run -d chrome --web-port 5000
   ```
   Emulador Android: `flutter run --dart-define=API_URL=http://10.0.2.2:8080/api`
   (en `android/app/src/main/AndroidManifest.xml` agrega `android:usesCleartextTraffic="true"` en `<application>`, porque el backend local usa http)
4. Pruebas: `flutter test`
