# Comandos para Flujo de Trabajo Git con Backport Automático

Este documento contiene todos los comandos necesarios para configurar y probar el flujo de trabajo Git con backport automático de hotfixes.

## Flujo Visual Completo

```
Feature Development:
  develop → feature/login → 3 commits → PR → Squash Merge → develop

Release/Hotfix Flow:
  develop → tag 1.0.0 → TRIGGER WORKFLOW:
                           ↓
                    [Deploy QAS] ✅ automático
                           ↓
                    [⏸️ APROBACIÓN MANUAL ⏸️]
                           ↓
                    [Deploy PRD] ✅ después de aprobar
                           ↓
                    [Backport to develop] ✅ solo si PRD OK
```

## Configuración Requerida en GitHub (IMPORTANTE)

Antes de ejecutar los comandos, debes configurar los **Environments** en GitHub:

### Paso 1: Crear Environment QAS

1. Ve a tu repositorio en GitHub
2. Settings → Environments → New environment
3. Nombre: `qas`
4. No agregar protection rules (deploy será automático)
5. Click en "Configure environment"

### Paso 2: Crear Environment Production con Aprobación

1. Settings → Environments → New environment
2. Nombre: `production`
3. **Activar:** Required reviewers
4. **Agregar:** Tu usuario y/o usuarios de tu equipo que pueden aprobar
5. Opcional: Wait timer (ej: 5 minutos de espera mínima antes de poder aprobar)
6. Click en "Configure environment"

**Sin estos environments configurados, el workflow fallará cuando intente usar `environment: production`.**

## 1. Setup Inicial

```bash
# Asegurarse de estar en develop
git checkout develop
git pull origin develop

# Verificar estado limpio
git status
```

## 2. Simulación de Feature

### Crear rama y hacer commits

```bash
# Crear y cambiar a rama feature
git checkout -b feature/login

# Commit 1: Estructura del componente
echo "// Login component" > login.js
git add login.js
git commit -m "feat: add login component structure"

# Commit 2: Lógica de validación
echo "// Login validation" >> login.js
git add login.js
git commit -m "feat: add login validation logic"

# Commit 3: Tests
echo "// Login tests" > login.test.js
git add login.test.js
git commit -m "test: add login component tests"

# Push de la rama al remoto
git push -u origin feature/login
```

### Crear Pull Request en GitHub

1. Ve a GitHub y crea un Pull Request de `feature/login` hacia `develop`
2. Usa **Squash and Merge** para mergear el PR
3. Esto convertirá los 3 commits en un solo commit en develop

### Actualizar develop localmente después del merge

```bash
# Volver a develop y actualizar con el squash merge
git checkout develop
git pull origin develop

# Verificar el nuevo commit
git log --oneline -3
```

## 3. Creación de Release Tag y Deploy

### Opción A: Script Automático (Recomendado)

El script automatiza todo el proceso:

```bash
# Dar permisos de ejecución (solo la primera vez)
chmod +x create-release.sh

# Crear release (incrementa PATCH automáticamente: 1.0.0 → 1.0.1)
./create-release.sh
```

El script hace automáticamente:
1. Obtiene el último tag
2. Incrementa la versión
3. Actualiza package.json
4. Crea commit en develop
5. Crea el tag
6. Push del commit y tag

### Opción B: Comandos Manuales

Si prefieres hacerlo manualmente:

```bash
# Obtener último tag
git describe --tags --abbrev=0

# Actualizar package.json manualmente a la nueva versión
npm version 1.0.0 --no-git-tag-version

# Hacer commit
git add package.json
git commit -m "chore: bump version to 1.0.0"

# Crear tag
git tag -a 1.0.0 -m "Release 1.0.0"

# Push commit y tag
git push origin develop
git push origin 1.0.0
```

**Importante:** Al hacer push del tag, se dispara automáticamente el workflow que:
1. Despliega a QAS automáticamente
2. Espera aprobación manual para PRD
3. Despliega a PRD (después de aprobar)
4. **NO hace backport** (las releases ya están en develop)

**Nota:** El backport solo se ejecuta para hotfixes (tags que terminan en .0).

### Aprobar Deploy a Producción

Después de que QAS se despliegue:

1. Ve a GitHub → Actions → Deploy and Backport
2. Verás el workflow esperando aprobación para el environment `production`
3. Haz clic en "Review deployments"
4. Selecciona `production` y haz clic en "Approve and deploy"
5. El job de PRD se ejecutará
6. Después del PRD exitoso, se ejecutará el backport automático a develop

## 4. Simulación de Hotfix

### Opción A: Script Automático para Hotfix (Recomendado)

```bash
# Dar permisos (solo la primera vez)
chmod +x create-hotfix.sh

# Primero, crear la rama hotfix desde el tag
git checkout -b hotfix/critical-bug 1.0.5

# Hacer cambios y commits
echo "// Bug fix applied" >> login.js
git add login.js
git commit -m "fix: resolve critical login bug"

# Push de la rama hotfix
git push origin hotfix/critical-bug

# Volver a develop para usar el script
git checkout develop

# Usar script de hotfix (incrementa MINOR: 1.0.5 → 1.1.0)
./create-hotfix.sh
```

**Nota:** Los hotfixes incrementan MINOR (1.0.5 → 1.1.0) mientras que releases incrementan PATCH (1.0.0 → 1.0.1).

### Opción B: Crear Hotfix Tag Manualmente

Si prefieres control total:

```bash
# Crear rama de hotfix desde el tag 1.0.5
git checkout -b hotfix/critical-bug 1.0.5

# Hacer el commit de fix
echo "// Bug fix applied" >> login.js
git add login.js
git commit -m "fix: resolve critical login bug"

# Push de la rama hotfix
git push origin hotfix/critical-bug

# Volver a develop
git checkout develop
git pull origin develop

# Actualizar package.json a 1.1.0 (incremento MINOR)
npm version 1.1.0 --no-git-tag-version

# Commit en develop
git add package.json
git commit -m "chore: bump version to 1.1.0"

# Crear tag
git tag -a 1.1.0 -m "Hotfix 1.1.0 - Critical login bug fix"

# Push de develop y tag
git push origin develop
git push origin 1.1.0
```

**Nota sobre el flujo automático:**

Al hacer push del tag `1.1.0`, se dispara el workflow completo:
1. ✅ Deploy a QAS (automático)
2. ⏸️ Espera aprobación para PRD (manual en GitHub UI)
3. ✅ Deploy a PRD (después de aprobar en GitHub)
4. ✅ **Backport a develop** (se ejecuta porque el tag termina en .0 = hotfix)

**Diferencia con releases:**
- Releases (1.0.1, 1.0.2): NO hacen backport (ya están en develop)
- Hotfixes (1.1.0, 1.2.0): SÍ hacen backport (vienen de rama hotfix)

## 5. Verificación del Flujo Completo

### Ver el estado del workflow en GitHub Actions

```bash
# Ver lista de ejecuciones del workflow
gh run list --workflow=backport-hotfix.yml

# Ver logs del último run
gh run view --log

# Ver status de un run específico
gh run view <run-id>
```

### Monitorear el Flujo Completo

En GitHub Actions verás:
1. ✅ Deploy QAS (completado automáticamente)
2. ⏸️ Deploy Production (esperando aprobación)
3. ⏳ Backport to Develop (esperando que PRD termine)

**Para aprobar PRD:** Ve al workflow en GitHub UI y haz clic en "Review deployments" → Approve

### Verificar que el commit está en develop

```bash
# Cambiar a develop
git checkout develop

# Actualizar desde remoto
git pull origin develop

# Ver el historial reciente (deberías ver el commit del hotfix)
git log --oneline -5

# Ver la diferencia entre el tag y develop
git log 1.0.0..develop --oneline
```

## 6. Resolución Manual de Conflictos (si es necesario)

Si el workflow falla por conflictos, verás el error en GitHub Actions. Para resolverlo manualmente:

```bash
# Checkout develop localmente
git checkout develop
git pull origin develop

# Obtener el SHA del commit del tag
git rev-list -n 1 1.0.1

# Cherry-pick manual del commit
git cherry-pick <commit-sha-del-tag>

# Si hay conflictos, Git los marcará en los archivos
# Edita los archivos para resolver los conflictos

# Después de resolver, agregar los archivos
git add .

# Continuar el cherry-pick
git cherry-pick --continue

# Push manual a develop
git push origin develop
```

## 7. Ejemplo de Secuencia: Releases y Hotfixes

Para ver cómo se incrementan las versiones:

```bash
# Release inicial
./create-release.sh  # 0.0.0 → 0.0.1

# Otra release
./create-release.sh  # 0.0.1 → 0.0.2

# Hotfix urgente (incrementa MINOR)
./create-hotfix.sh   # 0.0.2 → 0.1.0

# Más releases (continúan con PATCH)
./create-release.sh  # 0.1.0 → 0.1.1
./create-release.sh  # 0.1.1 → 0.1.2

# Otro hotfix
./create-hotfix.sh   # 0.1.2 → 0.2.0
```

**Patrón:**
- Releases = incremento PATCH
- Hotfixes = incremento MINOR (resetea PATCH a 0)

## 8. Comandos Útiles de Verificación

```bash
# Ver todas las ramas locales
git branch

# Ver todas las ramas remotas
git branch -r

# Ver todos los tags
git tag -l

# Ver el grafo de commits
git log --oneline --graph --all -10

# Ver diferencias entre ramas
git log develop..feature/login --oneline

# Ver qué commits están en develop pero no en un tag
git log 1.0.0..develop --oneline
```

## Flujo Completo de Trabajo

### Para Features

1. `git checkout -b feature/nueva-feature` (desde develop)
2. Hacer commits
3. `git push -u origin feature/nueva-feature`
4. Crear PR en GitHub hacia develop
5. Usar **Squash and Merge** en GitHub
6. `git checkout develop && git pull origin develop`

### Para Releases (Incremento PATCH)

**Con Script (Recomendado):**
```bash
git checkout develop
./create-release.sh
# Incrementa PATCH: 1.0.0 → 1.0.1
```

**Manual:**
```bash
git checkout develop
npm version 1.0.1 --no-git-tag-version
git add package.json
git commit -m "chore: bump version to 1.0.1"
git tag -a 1.0.1 -m "Release 1.0.1"
git push origin develop
git push origin 1.0.1
```

### Para Hotfixes (Incremento MINOR)

**Con Script (Recomendado):**
```bash
# 1. Crear rama hotfix y hacer fixes (opcional, solo para organización)
git checkout -b hotfix/bug-fix 1.0.5
# ... hacer cambios y commits ...
git push origin hotfix/bug-fix

# 2. Volver a develop y usar script de hotfix
git checkout develop
./create-hotfix.sh
# Incrementa MINOR: 1.0.5 → 1.1.0
```

**Manual:**
```bash
git checkout develop
npm version 1.1.0 --no-git-tag-version
git add package.json
git commit -m "chore: bump version to 1.1.0"
git tag -a 1.1.0 -m "Hotfix 1.1.0"
git push origin develop
git push origin 1.1.0
```

**Nota:** En ambos casos, después del push debes aprobar en GitHub Actions

## Resumen del Flujo Automático

### Para Releases (1.0.1, 1.0.2, etc.)
```
Push Tag 1.0.1
    ↓
Deploy QAS (automático)
    ↓
⏸️ PAUSA - Espera Aprobación Manual ⏸️
    ↓
Deploy PRD (después de aprobar)
    ↓
✅ FIN (NO backport, ya está en develop)
```

### Para Hotfixes (1.1.0, 1.2.0, etc.)
```
Push Tag 1.1.0
    ↓
Deploy QAS (automático)
    ↓
⏸️ PAUSA - Espera Aprobación Manual ⏸️
    ↓
Deploy PRD (después de aprobar)
    ↓
Backport a develop (solo si PRD OK)
    ↓
✅ FIN
```

**Puntos de control:**
- Aprobación manual es tu gate de calidad antes de PRD
- Backport automático solo para hotfixes (detectado por tag terminando en .0)

**Formato de tags:** Solo números (1.0.0, 1.0.1, 2.0.0, etc.) - sin prefijo 'v'
