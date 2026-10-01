/// URL base del backend Quarkus.
/// Se puede cambiar al ejecutar:
///   flutter run -d chrome --web-port 5000 --dart-define=API_URL=http://localhost:8080/api
/// En emulador Android usar: --dart-define=API_URL=http://10.0.2.2:8080/api
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080/api',
);
