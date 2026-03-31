# Quickstart: Git Workflow con Deploy Automático

Guía rápida para empezar a usar el flujo de trabajo.

## Prerequisitos

1. **Configurar Environments en GitHub** (solo una vez):
   - Ve a Settings → Environments
   - Crea `qas` (sin protección)
   - Crea `production` (con Required Reviewers)
   - Ver guía completa: [GITHUB_ENVIRONMENTS_SETUP.md](GITHUB_ENVIRONMENTS_SETUP.md)

2. **Dar permisos a los scripts:**
   ```bash
   chmod +x create-release.sh
   chmod +x create-hotfix.sh
   ```

## Flujo Típico

### 1. Desarrollar Feature

```bash
# Crear rama feature
git checkout -b feature/nueva-funcionalidad

# Hacer commits
git add .
git commit -m "feat: agregar nueva funcionalidad"

# Push
git push -u origin feature/nueva-funcionalidad
```

**Luego en GitHub:** Crear PR → Squash and Merge hacia `develop`

### 2. Crear Release

```bash
# Asegurarte de estar en develop actualizado
git checkout develop
git pull origin develop

# Ejecutar script (incrementa PATCH automáticamente)
./create-release.sh
```

El script te preguntará:
```
📌 Último tag: 1.0.0
🆕 Nueva versión (PATCH): 1.0.1
¿Crear release 1.0.1? (y/n)
```

Escribe `y` y presiona Enter.

**Nota:** Releases siempre incrementan PATCH (1.0.0 → 1.0.1 → 1.0.2)

### 3. Deploy Automático

El push del tag dispara automáticamente:

1. ✅ **Deploy a QAS** - Se ejecuta solo
2. ⏸️ **Espera Aprobación** - Ve a GitHub Actions
3. ✅ **Deploy a PRD** - Después de aprobar
4. ✅ **Backport a develop** - Solo para hotfixes (tags que terminan en .0)

**Nota:** 
- Releases (1.0.1, 1.0.2) → **NO** hacen backport (ya están en develop)
- Hotfixes (1.1.0, 1.2.0) → **SÍ** hacen backport

### 4. Aprobar Deploy a Producción

1. Ve a: `https://github.com/TU-ORG/TU-REPO/actions`
2. Click en el workflow "Deploy and Backport"
3. Verás: **"Waiting for approval"** (ícono amarillo ⏸️)
4. Click en **"Review deployments"**
5. Selecciona `production` → **"Approve and deploy"**

**IMPORTANTE:** Si el deploy a PRD corre sin esperar aprobación, ve a [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problema 9.

### 5. Verificar

```bash
# Ver status del workflow
gh run list --workflow=backport-hotfix.yml

# Ver logs
gh run view --log

# Actualizar develop local (ya incluye el backport)
git checkout develop
git pull origin develop
```

## Flujo de Hotfix

```bash
# 1. Crear rama desde tag específico
git checkout -b hotfix/fix-critico 1.0.5

# 2. Hacer fix y commit
echo "// Fix aplicado" >> archivo.js
git add archivo.js
git commit -m "fix: corregir bug crítico"

# 3. Push de la rama hotfix
git push origin hotfix/fix-critico

# 4. Volver a develop y crear tag con script de hotfix
git checkout develop
./create-hotfix.sh  # 1.0.5 → 1.1.0 (incrementa MINOR)

# 5. Aprobar en GitHub Actions (igual que release)
```

**Nota:** Hotfixes siempre incrementan MINOR y resetean PATCH (1.0.5 → 1.1.0)

## Comandos Rápidos

```bash
# Ver último tag
git describe --tags --abbrev=0

# Ver todos los tags
git tag -l

# Ver workflows en ejecución
gh run list

# Ver ramas
git branch -a

# Ver commits recientes
git log --oneline -10

# Ver grafo de commits
git log --oneline --graph --all -10
```

## Resumen Visual

```
                    DEVELOP
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
FEATURE            RELEASE            HOTFIX
    │                  │                  │
 3 commits      npm version patch    Fix commit
    │                  │                  │
Squash PR          1.0.0 tag         1.0.1 tag
    │                  │                  │
    └──────────────────┴──────────────────┘
                       │
                  WORKFLOW
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
    Deploy QAS    Deploy PRD    Backport
    (auto)        (manual)      (auto)
```

## Errores Comunes

### "You are not currently on a branch"

**Causa:** Estás en un tag o commit desconectado.

**Solución:**
```bash
git checkout develop
```

### "There is no tracking information for the current branch"

**Causa:** La rama no está conectada al remoto.

**Solución:**
```bash
git push -u origin develop
```

### "Updates were rejected because the remote contains work"

**Causa:** Develop local desactualizado.

**Solución:**
```bash
git pull origin develop
```

## Siguiente Paso

Lee la documentación completa en [GIT_WORKFLOW_COMMANDS.md](GIT_WORKFLOW_COMMANDS.md) para ver todos los comandos y opciones disponibles.
