# Scripts de Release y Hotfix

Este documento explica cómo usar los scripts automatizados para crear releases y hotfixes.

## Scripts Disponibles

- **`create-release.sh`** - Crea releases con incremento PATCH automático
- **`create-hotfix.sh`** - Crea hotfixes con incremento MINOR automático

## Uso Básico

```bash
# Dar permisos (solo la primera vez)
chmod +x create-release.sh
chmod +x create-hotfix.sh

# Crear release (incrementa PATCH: 1.0.0 → 1.0.1)
./create-release.sh

# Crear hotfix (incrementa MINOR: 1.0.5 → 1.1.0)
./create-hotfix.sh
```

## Diferencia entre Release y Hotfix

| Tipo | Script | Incremento | Ejemplo |
|------|--------|------------|---------|
| Release | `create-release.sh` | PATCH | 1.0.0 → 1.0.1 |
| Hotfix | `create-hotfix.sh` | MINOR | 1.0.5 → 1.1.0 |

## ¿Qué Hacen los Scripts?

### Script: create-release.sh

1. **Verifica prerrequisitos:**
   - Estás en la rama `develop`
   - No hay cambios sin commitear
   - Develop está actualizado

2. **Obtiene el último tag:**
   - Busca el tag más reciente en el repo
   - Si no hay tags, usa `0.0.0` como base

3. **Calcula nueva versión:**
   - **Incrementa PATCH automáticamente:** 1.0.0 → 1.0.1

4. **Pide confirmación:**
   - Te muestra la nueva versión
   - Espera tu confirmación (y/n)

5. **Actualiza package.json, commit, tag y push**

### Script: create-hotfix.sh

Igual que `create-release.sh` pero:
- **Incrementa MINOR y resetea PATCH:** 1.0.5 → 1.1.0
- Mensaje del tag: "Hotfix X.Y.Z"

## Ejemplos de Uso

### Ejemplo 1: Primera Release

```bash
# Estado actual: no hay tags
./create-release.sh

# Output:
# 📌 Último tag: 0.0.0
# 🆕 Nueva versión (PATCH): 0.0.1
# ¿Crear release 0.0.1? (y/n) y
# ✅ Release 0.0.1 creado exitosamente!
```

### Ejemplo 2: Release Normal

```bash
# Último tag: 1.0.0
./create-release.sh

# Output:
# 📌 Último tag: 1.0.0
# 🆕 Nueva versión (PATCH): 1.0.1
# ¿Crear release 1.0.1? (y/n) y
# ✅ Release 1.0.1 creado exitosamente!
```

### Ejemplo 3: Hotfix (MINOR)

```bash
# Último tag: 1.0.5
./create-hotfix.sh

# Output:
# 📌 Último tag: 1.0.5
# 🆕 Nueva versión (HOTFIX/MINOR): 1.1.0
# ¿Crear hotfix 1.1.0? (y/n) y
# ✅ Hotfix 1.1.0 creado exitosamente!
```

### Ejemplo 4: Secuencia de Releases y Hotfixes

```bash
# Release 1
./create-release.sh  # 0.0.0 → 0.0.1

# Release 2
./create-release.sh  # 0.0.1 → 0.0.2

# Hotfix urgente
./create-hotfix.sh   # 0.0.2 → 0.1.0

# Más releases
./create-release.sh  # 0.1.0 → 0.1.1
./create-release.sh  # 0.1.1 → 0.1.2
```

## Flujo Completo con el Script

```bash
# 1. Asegurarte de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Ejecutar script
./create-release.sh  # Para releases (patch)
# o
./create-hotfix.sh   # Para hotfixes (minor)

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

Los scripts incluyen validaciones:

- ✅ Verifica que estás en `develop`
- ✅ Verifica que no hay cambios sin commitear
- ✅ Actualiza develop antes de crear release/hotfix
- ✅ Pide confirmación antes de crear el tag

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

## Cuándo Usar Cada Script

| Situación | Script a Usar | Resultado |
|-----------|---------------|-----------|
| Release normal | `./create-release.sh` | 1.0.0 → 1.0.1 |
| Otra release | `./create-release.sh` | 1.0.1 → 1.0.2 |
| Bug crítico en producción | `./create-hotfix.sh` | 1.0.5 → 1.1.0 |
| Otro hotfix | `./create-hotfix.sh` | 1.1.0 → 1.2.0 |

## Para Incremento MAJOR (manual)

Si necesitas cambiar el major version (1.x.x → 2.0.0):

```bash
git checkout develop
npm version 2.0.0 --no-git-tag-version
git add package.json
git commit -m "chore: bump version to 2.0.0"
git tag -a 2.0.0 -m "Release 2.0.0"
git push origin develop
git push origin 2.0.0
```

## Comparación Script vs Manual

| Aspecto | Script | Manual |
|---------|--------|--------|
| Velocidad | ⚡ Un comando | 🐢 5-6 comandos |
| Errores | ✅ Validaciones automáticas | ⚠️ Propenso a errores |
| Flexibilidad | 🎯 patch o minor | 🔧 Cualquier versión |
| Aprendizaje | 📚 Abstracción | 🎓 Entiendes cada paso |

**Recomendación:** Usa los scripts para releases y hotfixes normales, manual para casos especiales (ej: major version).
