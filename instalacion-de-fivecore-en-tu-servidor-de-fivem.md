# 🚀 Instalación de FiveCore en tu servidor de FiveM

### 📦 Requisitos previos

Antes de comenzar, asegúrate de tener lo siguiente:

* Un servidor de **FiveM** configurado (local o VPS)
* Acceso a la carpeta `resources/`
* Base de datos MySQL/MariaDB activa (si tu versión de FiveCore la requiere)
* Una versión actualizada de **artifact** de FiveM
* Conocimientos básicos de estructura de recursos en FiveM

### 🧩 Paso 1: Descargar FiveCore

Puedes obtener la última versión de FiveCore desde el repositorio oficial:

bash

```
git clone https://github.com/TuUsuario/fivecore.git resources/[fivecore]
```

> Reemplaza `TuUsuario` por tu nombre de usuario en GitHub si estás usando tu propio repositorio.

### 🧩 Paso 3: Configurar la conexión a MongoDB

FiveCore se conecta directamente a MongoDB para almacenar datos del jugador, inventario, trabajos, etc. Asegúrate de tener una instancia activa de MongoDB y configura la conexión en el archivo `config.lua` o `.env` de tu framework:

lua

```
Config.MongoDB = {
  uri = "mongodb://localhost:27017",
  database = "fivecore"
}
```

> Puedes usar servicios como MongoDB Atlas si prefieres una solución en la nube.

### 🧩 Paso 4: Verificar instalación

Inicia tu servidor y verifica en la consola que FiveCore se haya cargado correctamente. Deberías ver algo como:

Código

```
[FiveCore] Conexión a MongoDB establecida.
[FiveCore] Framework iniciado correctamente.
```

### 🧩 Paso 5: Probar funciones básicas

Una vez en el servidor, puedes probar comandos básicos para verificar que el framework responde:

bash

```
/fivecoreinfo
/setjob [id] [trabajo]
/giveitem [id] [item] [cantidad]
```

> Estos comandos pueden variar según tu configuración personalizada.

### 🧠 Sugerencias

* Usa `ensure` en lugar de `start` para evitar conflictos de carga.
* Mantén FiveCore como base y carga tus recursos dependientes después.
* Documenta tus cambios en `config.lua` para mantener control de versiones.
* Si usás GitHub, considera usar GitHub Actions para automatizar pruebas y despliegues.

### ✅ Instalación completada

¡Listo! Tu servidor ahora está corriendo con FiveCore como framework principal, conectado a MongoDB. Desde aquí puedes comenzar a integrar sistemas como:

* Trabajo de policía
* Centro de empleos
* Inventario personalizado
* Tablet policial
* Armería y lockers
* Sistema judicial
