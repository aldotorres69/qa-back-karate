# Informe: Estrategia de automatización – API de Usuarios ServeRest

## 1. Alcance y objetivo

Validar el CRUD completo del recurso `/usuarios` de ServeRest según los criterios de aceptación de la historia de usuario:

| # | Criterio de aceptación | Escenarios que lo cubren |
|---|---|---|
| 1 | Obtener la lista de todos los usuarios | `listar-usuarios.feature` |
| 2 | Registrar un nuevo usuario con datos válidos | `registrar-usuario.feature` |
| 3 | Buscar un usuario específico por su ID | `buscar-usuario.feature` |
| 4 | Actualizar la información de un usuario existente | `actualizar-usuario.feature` |
| 5 | Eliminar un usuario del sistema | `eliminar-usuario.feature` |

## 2. Estrategia de pruebas

- **Un feature por endpoint**: cada archivo se lee como la especificación de una operación y se puede ejecutar por separado.
- **Positivos y negativos en cada endpoint**: camino feliz, validaciones de campos, reglas de negocio (email único, no eliminar usuarios con carrito, upsert de PUT) y errores de formato del ID.
- **Verificación de persistencia, no solo del status code**: después de cada POST o PUT se hace un `GET /usuarios/{_id}` para comprobar que los datos guardados son exactamente los enviados. En los PUT inválidos se comprueba además que el registro **no** cambió.
- **Validación de esquemas JSON**: todas las respuestas se comparan contra esquemas de `common/schemas` usando los marcadores *fuzzy* de Karate (`#string`, `#number`, `#regex`, `#[]`) y `match each` para las listas.
- **Independencia entre escenarios**: cada escenario crea sus propios datos y no depende del orden de ejecución. Por eso la suite corre **en paralelo** (5 hilos).
- **Limpieza de datos**: cada escenario elimina los usuarios que creó (y en el caso del carrito, cancela la compra para devolver el stock) para no ensuciar la API pública, que es compartida.
- **Etiquetado** (`@smoke`, `@positivo`, `@negativo` y una etiqueta por endpoint) para ejecutar subconjuntos en CI o en local.

## 3. Patrones y buenas prácticas aplicadas

| Patrón | Implementación | Beneficio |
|---|---|---|
| **Reusable feature / helper** | `common/helpers/crear-usuario.feature` y `eliminar-usuario.feature`, marcados `@ignore` e invocados con `call` | Evita duplicar el setup y el teardown; un único lugar para cambiar cómo se crea un usuario |
| **Test Data Builder** | `DataGenerator.java` (`usuario()`, `usuario(admin)`, `email()`, `idInexistente()`) | Datos únicos por ejecución (sufijo UUID), sin colisiones de email en un entorno compartido |
| **Data-Driven Testing** | `Scenario Outline` con `Examples` leídos desde `common/data/usuarios-invalidos.json` | Se añade un caso negativo nuevo editando un JSON, sin tocar el feature. El mismo set de datos se reutiliza en POST y PUT |
| **Schema as contract** | Esquemas JSON en `common/schemas` | El contrato de la respuesta se define una sola vez y se valida en todos los endpoints |
| **Configuración por entorno** | `karate-config.js` + `karate.env` | Se puede ejecutar contra `serverest.dev` o contra una instancia local sin cambiar el código |
| **Arrange / Act / Assert** | Background y llamadas a helpers (Arrange) → request (Act) → `status` + `match` (Assert) → limpieza | Escenarios legibles y fáciles de mantener |

### ¿Por qué el generador de datos está en Java y no en JavaScript?

En Karate 1.x, las funciones JavaScript definidas en `karate-config.js` se recrean a partir de su código fuente en cada hilo, así que pierden las variables de closure. Una clase Java con métodos estáticos es *thread-safe*, se puede reutilizar desde cualquier feature con `DataGenerator.usuario()` y deja crecer el generador sin esos problemas.

## 4. Comportamientos de la API detectados y documentados

- `GET /usuarios/{_id}` con un ID inexistente devuelve **400** (no 404) con `"Usuário não encontrado"`.
- `DELETE /usuarios/{_id}` con un ID inexistente devuelve **200** con `"Nenhum registro excluído"`: es idempotente.
- `PUT /usuarios/{_id}` con un ID inexistente **crea** el usuario (201): se comporta como upsert.
- El `_id` debe tener exactamente 16 caracteres alfanuméricos; si no, la API responde 400 con un mensaje de validación propio.

Estos comportamientos se validan tal como están documentados en ServeRest. En un proyecto real se reportarían como observaciones (por ejemplo, 404 para un recurso no encontrado) para que el equipo los revise.

## 5. Ejecución continua

`.github/workflows/ci.yml` ejecuta la suite en GitHub Actions en cada *push* o *pull request* y publica el reporte HTML de Karate como artefacto.

## 6. Posibles mejoras

- Levantar ServeRest en un contenedor dentro del pipeline (`karate.env=local`) para no depender de la disponibilidad de la API pública.
- Pruebas de rendimiento reutilizando los mismos features con **Karate Gatling**.
- Ampliar la suite al resto de recursos (`/login`, `/produtos`, `/carrinhos`) reutilizando los mismos helpers.
