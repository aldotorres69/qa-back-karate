# QA Back – Automatización API de Usuarios ServeRest con Karate DSL

Suite de pruebas automatizadas para la **API de Usuarios** de [ServeRest](https://serverest.dev/) construida con **Karate DSL 1.5.1** + **JUnit 5** + **Maven**.

## Historia de usuario

> **Como** administrador del sistema, **quiero** poder gestionar los usuarios a través de la API, **para** administrar la base de datos de usuarios.

## Cobertura

| Endpoint | Feature | Positivos | Negativos |
|---|---|---|---|
| `GET /usuarios` | `listar-usuarios.feature` | Listado completo + esquema, filtro por `_id`, `email`, `nome`, filtro sin resultados | `administrador` con valor no permitido |
| `POST /usuarios` | `registrar-usuario.feature` | Registro admin `true` / `false` y verificación de persistencia | Email duplicado, body vacío, 10 casos data-driven de campos inválidos |
| `GET /usuarios/{_id}` | `buscar-usuario.feature` | Búsqueda por ID + esquema | ID inexistente, 3 formatos de ID inválidos, usuario ya eliminado |
| `PUT /usuarios/{_id}` | `actualizar-usuario.feature` | Actualización total, cambio parcial de perfil, upsert con ID inexistente | Email de otro usuario, 10 casos data-driven de campos inválidos (verificando que el registro no cambia) |
| `DELETE /usuarios/{_id}` | `eliminar-usuario.feature` | Eliminación + verificación | ID inexistente, doble eliminación, usuario con carrito registrado |

**Total: 5 features · 44 escenarios** (contando cada fila de los Examples).

## Requisitos previos

- **Java 17 o superior** (probado con Java 21). Verificar con `java -version`.
- Conexión a internet hacia `https://serverest.dev`.
- **No hace falta instalar Maven**: el proyecto incluye Maven Wrapper (`mvnw` / `mvnw.cmd`).

## Ejecución

```bash
# Clonar
git clone <url-del-repositorio>
cd qa-back-karate

# Ejecutar toda la suite (Linux / macOS / Git Bash)
./mvnw test

# Windows (CMD / PowerShell)
mvnw.cmd test
```

### Ejecutar por tags

```bash
./mvnw test -Dkarate.options="--tags @smoke"       # un escenario principal por endpoint
./mvnw test -Dkarate.options="--tags @negativo"    # solo casos negativos
./mvnw test -Dkarate.options="--tags @registrar"   # solo POST /usuarios
```

Tags disponibles: `@usuarios`, `@listar`, `@registrar`, `@buscar`, `@actualizar`, `@eliminar`, `@smoke`, `@positivo`, `@negativo`.

### Ejecutar un feature concreto

```bash
./mvnw test -Dkarate.options="classpath:serverest/usuarios/buscar-usuario.feature"
```

### Cambiar de entorno

La URL base se define en `karate-config.js` según `karate.env`:

| `karate.env` | URL |
|---|---|
| `prod` (por defecto) | `https://serverest.dev` |
| `local` | `http://localhost:3000` (ServeRest local: `npx serverest@latest`) |

```bash
./mvnw test -Dkarate.env=local
```

## Reportes

Al terminar, Karate genera el reporte HTML en:

```
target/karate-reports/karate-summary.html
```

También se generan el JSON de Cucumber (`target/karate-reports/*.json`), los resultados JUnit (`target/surefire-reports`) y el log completo (`target/karate.log`).

## Estructura del proyecto

```
qa-back-karate/
├── pom.xml                         # Dependencias (karate-junit5) y surefire
├── mvnw / mvnw.cmd / .mvn/         # Maven Wrapper
├── .github/workflows/ci.yml        # Ejecución en GitHub Actions
├── docs/ESTRATEGIA.md              # Informe de estrategia y patrones
└── src/test/java/
    ├── karate-config.js            # Configuración global: entorno, baseUrl, timeouts
    ├── logback-test.xml            # Logging
    └── serverest/
        ├── usuarios/               # Un feature por endpoint + runner
        │   ├── UsuariosRunner.java
        │   ├── listar-usuarios.feature
        │   ├── registrar-usuario.feature
        │   ├── buscar-usuario.feature
        │   ├── actualizar-usuario.feature
        │   └── eliminar-usuario.feature
        └── common/
            ├── helpers/            # Features reutilizables (@ignore): crear / eliminar usuario
            ├── schemas/            # Esquemas JSON de respuesta
            ├── data/               # Datos para escenarios data-driven
            └── utils/              # DataGenerator.java: generación de datos de prueba
```

## Informe de estrategia

La estrategia de automatización, los patrones usados y las decisiones de diseño están en [`docs/ESTRATEGIA.md`](docs/ESTRATEGIA.md).
