# 🧩 Estructura del Framework — FiveCore

### 🧠 Visión general

FiveCore es un framework modular diseñado para servidores de FiveM que utilizan **MongoDB** como base de datos. Su arquitectura está pensada para ser clara, extensible y fácil de mantener. Cada componente del sistema está separado por responsabilidad, lo que permite escalar sin romper compatibilidad.

### 📁 Organización de carpetas

Código

```
resources/
├── fivecore/
│   ├── fxmanifest.lua
│   ├── config.lua
│   ├── server/
│   │   ├── core.lua
│   │   ├── database.lua
│   │   ├── jobs.lua
│   │   ├── inventory.lua
│   │   └── permissions.lua
│   ├── client/
│   │   ├── core.lua
│   │   ├── ui.lua
│   │   └── events.lua
│   ├── shared/
│   │   ├── items.lua
│   │   └── jobs.lua
```

### 🔧 Módulos principales

#### `server/core.lua`

* Inicializa el framework y gestiona el estado del jugador.
* Expone funciones como `state(source)` para acceder a datos del jugador.

#### `server/database.lua`

* Conecta con MongoDB.
* Maneja operaciones CRUD para ciudadanos, inventario, trabajos, etc.

#### `server/jobs.lua`

* Define y gestiona los trabajos disponibles.
* Permite asignar, cambiar y validar roles.

#### `server/inventory.lua`

* Controla el inventario del jugador.
* Funciones para añadir, quitar, verificar ítems.

#### `server/permissions.lua`

* Sistema de permisos por rango o rol.
* Verifica si un jugador puede usar ciertos ítems o acceder a funciones.

### 🧑‍💻 Cliente

#### `client/core.lua`

* Maneja eventos del jugador (spawn, login, etc.).
* Sincroniza datos con el servidor.

#### `client/ui.lua`

* Controla interfaces NUI como tablet policial, centro de trabajos, etc.

#### `client/events.lua`

* Escucha y responde a eventos personalizados del servidor.

### 📦 Compartido

#### `shared/items.lua`

* Define todos los ítems disponibles en el servidor.
* Incluye nombre, peso, descripción, si es usable o stackable.

#### `shared/jobs.lua`

* Define los trabajos disponibles y sus propiedades.
* Incluye nombre, rango, sueldo, permisos, etc.

### 🧩 Cómo se conectan los módulos

* El servidor inicializa `fivecore` y carga los datos del jugador desde MongoDB.
* Cada recurso (como `police_job`, `jobcenter`, etc.) accede al estado del jugador mediante `exports['fivecore']:state(source)`.
* Los módulos cliente se comunican con el servidor mediante eventos (`TriggerServerEvent`, `RegisterNetEvent`).
* Las interfaces NUI se conectan mediante `SendNUIMessage` y `RegisterNUICallback`.

### 🧠 Buenas prácticas

* Mantén cada módulo enfocado en una sola responsabilidad.
* Usa `exports['fivecore']` para acceder a funciones comunes desde otros recursos.
* Documenta tus funciones y eventos personalizados.
* Evita modificar directamente los archivos núcleo; usa extensiones o hooks.

### ✅ ¿Qué sigue?

Ahora que conocés la estructura de FiveCore, podés:

* Crear nuevos módulos personalizados (ej. sistema de empresas, sistema de salud)
* Integrar scripts externos usando el puente de compatibilidad
* Contribuir al desarrollo del framework desde GitHub.
