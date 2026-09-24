# Plantacert AI – Backend Quarkus (Grupo 5)

Migración del backend de Plantacert AI (antes FastAPI) a **Quarkus (Java)**, siguiendo la
estructura por capas de la guía del profesor (`dominio`, `aplicacion`, `infraestructura`, `common`).

## Historias implementadas en este sprint

| HU | Descripción | Endpoint |
|----|-------------|----------|
| RQ1-HU01 | Registro de usuario (nombre, correo, contraseña ≥ 8) | `POST /api/usuarios/registro` |
| RQ4-HU01 | Agregar planta al catálogo (nombre, especie, ubicación, descripción, URL de foto) | `POST /api/plantas/usuario/{usuarioId}` |
| RQ4-HU01 | Ver las plantas del usuario (para verificar el registro) | `GET /api/plantas/usuario/{usuarioId}` |

> Mientras no exista el login con JWT (RQ-02), el usuario dueño de la planta se envía en la URL.

## Estructura

```
src/main/java/edu/ucentral/plantacert
├── InfoRecurso.java                 GET /api/info/version
├── common
│   ├── excepciones                  NegocioException + mappers de errores (400, 404, 409)
│   └── respuesta                    ResponseApi / ResponseApiError (formato de error)
├── dominio                          Entidades y repositorios Panache (Usuario, Planta)
├── aplicacion                       Servicios con la lógica de negocio
└── infraestructura                  Recursos REST y DTOs (payloads / respuestas)
```

## Ejecutar en IntelliJ IDEA

1. `File > Open` y seleccionar la carpeta del proyecto (IntelliJ detecta el `pom.xml`).
2. `File > Project Structure > Project > SDK`: JDK 25 (si usas JDK 21, cambia `maven.compiler.release` a 21 en el `pom.xml`).
3. `Settings > Build, Execution, Deployment > Compiler > Annotation Processors`: marcar **Enable annotation processing** (Lombok).
4. Copiar `.env.example` como `.env` (opcional, por defecto usa H2 en memoria).
5. En la terminal de IntelliJ:
   - Modo desarrollo: `.\mvnw quarkus:dev`  (Linux/Mac: `./mvnw quarkus:dev`)
   - Pruebas: `.\mvnw test`
6. Swagger: http://localhost:8080/swagger-ui/ — Dev UI: http://localhost:8080/api/q/dev-ui

### Ejemplos de prueba (Swagger o Postman)

```json
POST /api/usuarios/registro
{ "nombre": "Valeria Gómez", "correo": "valeria@correo.com", "contrasena": "clave1234" }
```

```json
POST /api/plantas/usuario/1
{ "nombre": "Monstera", "especie": "Monstera deliciosa", "ubicacion": "Sala",
  "descripcion": "Hojas grandes", "imagenUrl": "https://ejemplo.com/monstera.jpg" }
```

## Ramas (entornos) del repositorio

| Rama | Uso |
|------|-----|
| `main` | Versión estable / entrega final del sprint |
| `develop` | Entorno **dev**: integra las HU ya probadas |
| `test` | Entorno de **pruebas**: aquí se fusiona primero cada HU para no tumbar `develop` |
| `feature/RQ1-HU01-registro-usuario` | Rama de la HU de registro |
| `feature/RQ4-HU01-registro-planta` | Rama de la HU de registrar planta |

Flujo: `feature/...` → PR a `test` (CI en verde + prueba manual en Swagger) → PR a `develop` → al cierre del sprint `develop` → `main`.

El workflow `.github/workflows/ci.yml` compila y corre las pruebas en cada push y Pull Request.
