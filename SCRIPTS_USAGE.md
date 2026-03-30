# Scripts de Release y Hotfix

Este documento explica cómo usar los scripts automatizados para crear releases y hotfixes.

## Scripts Disponibles

- **`create-release.sh`** - Para Linux/Mac/Git Bash
- **`create-release.ps1`** - Para Windows PowerShell

Ambos hacen lo mismo, usa el apropiado para tu sistema.

## Uso Básico

### Linux/Mac/Git Bash

```bash
# Dar permisos (solo la primera vez)
chmod +x create-release.sh

# Crear release con incremento patch (1.0.0 → 1.0.1)
./create-release.sh patch

# Crear release con incremento minor (1.0.0 → 1.1.0)
./create-release.sh minor

# Crear release con incremento major (1.0.0 → 2.0.0)
./create-release.sh major

# Por defecto es patch si no especificas
./create-release.sh
```

### Windows PowerShell

```powershell
# Crear release con incremento patch (1.0.0 → 1.0.1)
.\create-release.ps1 -Type patch

# Crear release con incremento minor (1.0.0 → 1.1.0)
.\create-release.ps1 -Type minor

# Crear release con incremento major (1.0.0 → 2.0.0)
.\create-release.ps1 -Type major

# Por defecto es patch si no especificas
.\create-release.ps1
```

## ¿Qué Hace el Script?

1. **Verifica prerrequisitos:**
   - Estás en la rama `develop`
   - No hay cambios sin commitear
   - Develop está actualizado

2. **Obtiene el último tag:**
   - Busca el tag más reciente en el repo
   - Si no hay tags, usa `0.0.0` como base

3. **Calcula nueva versión:**
   - **patch:** Incrementa el último número (1.0.0 → 1.0.1)
   - **minor:** Incrementa el segundo número (1.0.0 → 1.1.0)
   - **major:** Incrementa el primer número (1.0.0 → 2.0.0)

4. **Pide confirmación:**
   - Te muestra la nueva versión
   - Espera tu confirmación (y/n)

5. **Actualiza package.json:**
   - Usa `npm version` para actualizar
   - NO crea tag automático de npm

6. **Crea commit en develop:**
   - Commit mensaje: `"chore: bump version to X.Y.Z"`
   - Solo incluye package.json

7. **Crea tag:**
   - Tag anotado con mensaje descriptivo

8. **Push:**
   - Sube el commit a develop
   - Sube el tag
   - **Esto dispara el workflow de deploy automáticamente**

## Ejemplos de Uso

### Ejemplo 1: Primera Release

```bash
# Estado actual: no hay tags
./create-release.sh minor

# Output:
# 📌 Último tag: 0.0.0
# 🆕 Nueva versión: 0.1.0
# ¿Crear release 0.1.0? (y/n) y
# ✅ Release 0.1.0 creado exitosamente!
```

### Ejemplo 2: Hotfix

```bash
# Último tag: 1.0.0
./create-release.sh patch

# Output:
# 📌 Último tag: 1.0.0
# 🆕 Nueva versión: 1.0.1
# ¿Crear release 1.0.1? (y/n) y
# ✅ Release 1.0.1 creado exitosamente!
```

### Ejemplo 3: Major Release

```bash
# Último tag: 1.5.3
./create-release.sh major

# Output:
# 📌 Último tag: 1.5.3
# 🆕 Nueva versión: 2.0.0
# ¿Crear release 2.0.0? (y/n) y
# ✅ Release 2.0.0 creado exitosamente!
```

## Flujo Completo con el Script

```bash
# 1. Asegurarte de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Ejecutar script
./create-release.sh patch

# 3. El script hace todo automáticamente:
#    - Actualiza package.json
#    - Commit a develop
#    - Crea tag
#    - Push de ambos

# 4. Verificar en GitHub Actions
gh run list --workflow=backport-hotfix.yml

# 5. Aprobar deploy a PRD cuando QAS esté OK
#    (en GitHub UI: Actions → Review deployments)
```

## Verificaciones de Seguridad

El script incluye validaciones:

- ✅ Verifica que estás en `develop`
- ✅ Verifica que no hay cambios sin commitear
- ✅ Actualiza develop antes de crear release
- ✅ Pide confirmación antes de crear el tag
- ✅ Valida el tipo de incremento (patch/minor/major)

## Troubleshooting

### Error: "Debes estar en la rama develop"

**Solución:**
```bash
git checkout develop
```

### Error: "Hay cambios sin commitear"

**Solución:**
```bash
# Ver qué cambios hay
git status

# Commitear o descartar cambios
git add .
git commit -m "tu mensaje"
# O
git restore .
```

### Error: "npm: command not found"

**Solución:** Instala Node.js y npm, o actualiza package.json manualmente:
```bash
# Editar package.json y cambiar "version": "1.0.1"
# Luego continuar con git add, commit, tag, push
```

### Quiero especificar una versión exacta

Si quieres control total sobre el número de versión:

```bash
# No uses el script, hazlo manual:
npm version 2.5.7 --no-git-tag-version
git add package.json
git commit -m "chore: bump version to 2.5.7"
git tag -a 2.5.7 -m "Release 2.5.7"
git push origin develop
git push origin 2.5.7
```

## Comparación Script vs Manual

| Aspecto | Script | Manual |
|---------|--------|--------|
| Velocidad | ⚡ Muy rápido | 🐢 Varios comandos |
| Errores | ✅ Validaciones automáticas | ⚠️ Propenso a errores |
| Flexibilidad | 🎯 patch/minor/major | 🔧 Versión exacta |
| Aprendizaje | 📚 Abstracción | 🎓 Entiendes cada paso |

**Recomendación:** Usa el script para day-to-day, manual para casos especiales.
