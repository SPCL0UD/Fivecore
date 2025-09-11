# 👷 Sistema de trabajos en FiveCore

FiveCore incluye un sistema modular de trabajos que permite a los jugadores acceder a empleos básicos como **camionero**, **basurero**, **repartidor**, entre otros. Cada trabajo está diseñado para ser simple de usar, visualmente limpio y fácil de extender por otros desarrolladores.

#### 📁 Estructura de los trabajos

Cada trabajo se organiza como un recurso independiente dentro de `resources/`, por ejemplo:

Código

```
resources/
├── job_truckdriver/
├── job_garbage/
├── job_delivery/
```

Cada uno incluye:

* `fxmanifest.lua` con dependencias mínimas
* `config.lua` con rutas, pagos y puntos de interacción
* `client/main.lua` para lógica visual y eventos
* `server/main.lua` para pagos, validaciones y estado

#### 🧩 Integración con FiveCore

Todos los trabajos se conectan al framework mediante:

lua

```
local p = exports['fivecore']:state(source)
```

Desde ahí, se accede a:

* `p.job` → Verifica si el jugador tiene el trabajo activo
* `p.money.cash` → Añade pagos por tareas completadas
* `p.inventory` → Entrega ítems si el trabajo lo requiere

#### 🚚 Ejemplo: Trabajo de Camionero

* El jugador recoge mercancía en un depósito.
* Lleva el camión a distintos puntos de entrega.
* Recibe pago por cada entrega completada.
* Se puede configurar para usar trailers, rutas largas o entregas especiales.

**Integración externa:** Si querés usar un script de terceros para spawn de vehículos, simplemente conectalo con `p.job == 'truckdriver'` y usá `exports['fivecore']:state(source)` para validar.

#### 🗑️ Ejemplo: Trabajo de Basurero

* El jugador recoge bolsas de basura en puntos marcados.
* Usa un camión de basura para transportarlas.
* Recibe pago por cada bolsa entregada en el centro de reciclaje.

**Integración externa:** Podés usar scripts como `aty-trashjob` o `quasar-garbage` adaptando sus eventos para que usen el estado del jugador desde FiveCore.

#### 📦 Ejemplo: Trabajo de Repartidor

* El jugador recibe paquetes en una oficina.
* Los entrega en casas o negocios marcados en el mapa.
* Recibe pago por cada entrega exitosa.

**Integración externa:** Si usás scripts como `buty-delivery`, podés reemplazar sus llamadas a `QBCore.Functions.GetPlayer` por `exports['fivecore']:state(source)`.

#### 🧠 Cómo crear tu propio trabajo

1. Crea una carpeta `job_nombre/` dentro de `resources/`
2. Define puntos en `config.lua`
3. Usa `p = exports['fivecore']:state(source)` para acceder al jugador
4. Usa `p.job` para validar el rol
5. Usa `p.money.cash = p.money.cash + cantidad` para pagar

#### 🔌 Conectar scripts externos

Para adaptar scripts de otros desarrolladores:

* Reemplazá `QBCore.Functions.GetPlayer(source)` por `exports['fivecore']:state(source)`
* Usá `p.job` para verificar el trabajo activo
* Usá `p.inventory` para entregar ítems
* Usá `p.money.cash` para pagos

### ✅ Ventajas del sistema de trabajos en FiveCore

* Modular: cada trabajo es independiente
* Extensible: fácil de conectar con scripts externos
* Visual: puntos interactivos con NPCs y NUI
* Limpio: sin comandos innecesarios, todo es inmersivo
* Compatible: con MongoDB y tu sistema de estado personalizado
