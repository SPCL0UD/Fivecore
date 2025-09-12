---
description: >-
  Hola nuevamente en esta página veras como usar Fivecore con txadmin mediante
  un témplate récipe.
---

# Uso de txadmin con Fivecore

### 🧩 Cómo cargar tu receta personalizada en txAdmin

#### ✅ Opción 1: Usar archivo local

1. Abre txAdmin en tu navegador (por ejemplo: `http://localhost:40120`)
2. En el menú lateral, seleccioná **“Create New Server”**
3. Elegí la opción **“Custom Recipe”**
4. En el campo **“Upload Recipe File”**, seleccioná tu archivo `recipe.yaml` desde tu PC
5. txAdmin lo validará y te mostrará un resumen de los recursos y configuraciones
6. Confirmá y hacé clic en **“Create Server”**

#### ✅ Opción 2: Usar receta desde GitHub

Si tenés tu receta publicada en GitHub, podés usar el enlace directo al archivo `recipe.yaml`:

1. Asegurate de que el archivo esté en un repositorio público (ejemplo: `https://github.com/SPCL0UD/fivecore-recipe/blob/main/recipe.yaml`)
2. Copiá el enlace **RAW** del archivo (debe terminar en `.yaml`, como: `https://raw.githubusercontent.com/SPCL0UD/fivecore-recipe/main/recipe.yaml`)
3. En txAdmin, seleccioná **“Custom Recipe”**
4. Pegá el enlace en el campo **“Recipe URL”**
5. txAdmin descargará y ejecutará la receta automáticamente
