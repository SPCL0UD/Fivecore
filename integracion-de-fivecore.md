---
description: >-
  Hola de nuevo en este apartado veras la manera de poder integrar tu scripts
  que tu puedas crear a tu semejanza con nuestro framework llamado Fivecore.
icon: integral
---

# Integración de FiveCore

## 📘 Guía de Integración de Scripts Externos en FiveCore

### 🧠 Introducción

FiveCore es un framework modular, moderno y altamente personalizable para servidores de FiveM. Esta guía explica cómo adaptar scripts de terceros (como Aty, Quasar Store, ButyShop, etc.) para que funcionen correctamente dentro del ecosistema de FiveCore, manteniendo compatibilidad, seguridad y estilo.

### 🧩 Estructura base de FiveCore

FiveCore gestiona los datos del jugador mediante un sistema centralizado. Las funciones clave son: `local p = exports['fivecore']:state(source)`

Desde `p`, puedes acceder a:

* `p.money.cash` → Dinero en efectivo
* `p.inventory` → Inventario del jugador
* `p.job` → Trabajo actual
* `p.citizenid` → ID único del ciudadano
* `p.policeXP` → Experiencia policial (si aplica)

#### ✅ 1. Reemplazar funciones de frameworks como QBCore o ESX

| Función en QBCore / ESX                   | Equivalente en FiveCore                                     |
| ----------------------------------------- | ----------------------------------------------------------- |
| `QBCore.Functions.GetPlayer(source)`      | `exports['fivecore']:state(source)`                         |
| `Player.Functions.AddMoney('cash', x)`    | `p.money.cash = p.money.cash + x`                           |
| `Player.Functions.RemoveMoney('cash', x)` | `p.money.cash = p.money.cash - x`                           |
| `Player.Functions.AddItem(name, count)`   | `table.insert(p.inventory, { name = name, count = count })` |
| `Player.Functions.SetJob(job, grade)`     | `p.job = job`                                               |

#### ✅ 2. Crear un puente de compatibilidad

Puedes crear un archivo llamado `fivecore_bridge.lua` para centralizar las conversiones:

lua

```
Framework = {}

function Framework.GetPlayer(src)
  return exports['fivecore']:state(src)
end

function Framework.AddMoney(p, amount)
  p.money.cash = p.money.cash + amount
end

function Framework.RemoveMoney(p, amount)
  p.money.cash = p.money.cash - amount
end

function Framework.HasItem(p, item)
  for _, i in ipairs(p.inventory) do
    if i.name == item and i.count > 0 then return true end
  end
  return false
end
```

#### ✅ 3. Adaptar eventos y callbacks

Si el script externo usa `QBCore:Server:Callback`, reemplázalo por eventos estándar:

lua

```
RegisterNetEvent('script:accion', function(data)
  local p = exports['fivecore']:state(source)
  -- lógica adaptada
end)
```

#### ✅ 4. Integrar inventario y apariencias

Si el script maneja ropa, accesorios o props, asegúrate de que tu sistema de apariencia esté sincronizado:

lua

```
exports['fivecore']:setAppearance(PlayerId(), {
  torso = 55,
  pants = 35,
  shoes = 25
})
```

### 🛍️ Ejemplo: Adaptar Quasar Store

**Original (QBCore):**

lua

```
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.RemoveMoney('cash', price)
Player.Functions.AddItem(item, 1)
```

**Adaptado a FiveCore:**

lua

```
local p = exports['fivecore']:state(source)
if p.money.cash >= price then
  p.money.cash = p.money.cash - price
  table.insert(p.inventory, { name = item, count = 1 })
end
```

### 🧪 Pruebas y validación

Antes de publicar una integración:

1. Verifica que el script no dependa de funciones exclusivas de otro framework.
2. Reemplaza todas las llamadas a `Player.Functions` por equivalentes de FiveCore.
3. Prueba en entorno local con logs activos.
4. Documenta los cambios en un archivo `README.md` dentro del recurso.
