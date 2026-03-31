# Troubleshooting: Problemas Comunes

## Problema 1: Deploy a PRD corre sin aprobación

### Síntoma
El workflow despliega a producción automáticamente sin esperar aprobación manual.

### Causa
El environment `production` en GitHub no tiene configurado "Required reviewers".

### Solución

1. Ve a tu repositorio en GitHub
2. **Settings** → **Environments** → **production**
3. En "Environment protection rules":
   - ✅ Activa **"Required reviewers"**
   - Click en el campo y selecciona los revisores
   - Agrega al menos 1 revisor (tu usuario)
4. Scroll abajo y click en **"Save protection rules"**

### Verificar que está configurado

Deberías ver en el environment `production`:
```
Environment protection rules
✅ Required reviewers (1 reviewer)
   - @tu-usuario
```

### Probar de nuevo

```bash
# Crear un nuevo tag de prueba
git tag -a 1.0.3 -m "Test approval"
git push origin 1.0.3
```

Ahora deberías ver en GitHub Actions:
- Deploy QAS: ✅ Completado
- Deploy Production: ⏸️ **Waiting for approval**

## Problema 2: Backport se ejecuta para releases (no debería)

### Síntoma
El backport a develop se ejecuta incluso cuando creas releases desde develop.

### Causa
El workflow original hacía backport para TODOS los tags.

### Solución (Ya Aplicada)

El workflow ahora incluye esta condición:

```yaml
backport-to-develop:
  needs: deploy-prd
  if: endsWith(github.ref_name, '.0')  # Solo si termina en .0 (hotfix)
```

**Lógica:**
- **Releases (PATCH):** 1.0.1, 1.0.2, 1.0.3 → No termina en .0 → **NO backport**
- **Hotfixes (MINOR):** 1.1.0, 1.2.0, 1.3.0 → Termina en .0 → **SÍ backport**

### Verificar

Después de crear un release:
```bash
./create-release.sh  # Crea 1.0.1
```

En GitHub Actions deberías ver:
- Deploy QAS: ✅
- Deploy PRD: ✅ (después de aprobar)
- Backport: ⏭️ **Skipped** (porque no termina en .0)

Después de crear un hotfix:
```bash
./create-hotfix.sh  # Crea 1.1.0
```

En GitHub Actions deberías ver:
- Deploy QAS: ✅
- Deploy PRD: ✅ (después de aprobar)
- Backport: ✅ **Ejecutado** (porque termina en .0)

## Problema 3: "Environment not found"

### Síntoma
```
Error: Environment production not found
```

### Causa
No has creado el environment en GitHub.

### Solución
Sigue la guía completa: [GITHUB_ENVIRONMENTS_SETUP.md](GITHUB_ENVIRONMENTS_SETUP.md)

## Problema 4: Script no tiene permisos

### Síntoma
```bash
./create-release.sh
bash: ./create-release.sh: Permission denied
```

### Solución
```bash
chmod +x create-release.sh
chmod +x create-hotfix.sh
```

## Problema 5: "fatal: tag already exists"

### Síntoma
El script falla porque el tag ya existe.

### Causa
Ya creaste ese tag anteriormente.

### Solución

Opción A - Eliminar tag local y remoto:
```bash
# Eliminar tag local
git tag -d 1.0.1

# Eliminar tag remoto
git push origin :refs/tags/1.0.1
```

Opción B - Continuar con la siguiente versión:
```bash
# El script automáticamente usará la siguiente versión
./create-release.sh
```

## Problema 6: Cherry-pick falla con conflictos

### Síntoma
El job de backport falla con:
```
error: could not apply... fix: some change
hint: Resolve all conflicts manually
```

### Causa
Hay conflictos entre el commit del hotfix y develop.

### Solución Manual

```bash
# 1. Checkout develop
git checkout develop
git pull origin develop

# 2. Obtener SHA del tag problemático
git rev-list -n 1 1.1.0

# 3. Cherry-pick manual
git cherry-pick <commit-sha>

# 4. Git marcará archivos con conflictos
# Edita cada archivo y resuelve los conflictos

# 5. Después de resolver
git add .
git cherry-pick --continue

# 6. Push manual
git push origin develop
```

## Problema 7: "You are not currently on a branch"

### Síntoma
```
Error: Debes estar en la rama develop
```

### Causa
Estás en modo "detached HEAD" (en un tag o commit específico).

### Solución
```bash
git checkout develop
```

## Problema 8: Workflow no se dispara

### Síntoma
Haces push de un tag pero no aparece el workflow en Actions.

### Causa Posible 1: Formato de tag incorrecto

El workflow espera formato `X.Y.Z` (números con puntos).

**Verifica:**
```bash
# Correcto
1.0.0, 1.0.1, 2.3.4

# Incorrecto (no dispara workflow)
v1.0.0, release-1.0.0, 1.0
```

### Causa Posible 2: Archivo workflow no está en rama correcta

**Verifica:**
```bash
git ls-tree develop .github/workflows/backport-hotfix.yml
```

Si no aparece nada, el archivo no está en develop.

**Solución:**
```bash
git checkout develop
git status  # Verifica que backport-hotfix.yml existe
git add .github/workflows/backport-hotfix.yml
git commit -m "chore: add deploy and backport workflow"
git push origin develop
```

## Problema 9: Environment protection configurado pero no pide aprobación

### Pasos de Verificación Detallada

1. Ve a Settings → Environments → production
2. Verifica que veas exactamente esto:

```
Environment protection rules
☑️ Required reviewers
   Reviewers (1/6)
   @tu-usuario
   
   [Save protection rules]
```

3. **IMPORTANTE:** Después de configurar, debes hacer click en **"Save protection rules"** al final de la página

4. Verifica que el botón NO esté disponible (ya guardaste)

5. Crea un nuevo tag de prueba:
```bash
git tag -a 1.0.99 -m "Test"
git push origin 1.0.99
```

6. Ve a Actions inmediatamente y observa:
   - Deploy QAS debería completarse rápido
   - Deploy PRD debería decir **"Waiting for approval"** con un ícono amarillo

### Si aún no funciona

Verifica en el workflow run (GitHub Actions):
- Click en el workflow run
- Click en el job "Deploy to Production"
- Si dice "Complete job" en vez de "Review pending deployments", el environment no está bien configurado

### Última opción: Recrear environment

1. Settings → Environments
2. Click en "production"
3. Click en "Delete environment" (al final)
4. Crear de nuevo siguiendo [GITHUB_ENVIRONMENTS_SETUP.md](GITHUB_ENVIRONMENTS_SETUP.md)

## Necesitas Ayuda

Si ninguna de estas soluciones funciona:

1. Ve al workflow run en GitHub Actions
2. Copia el URL del workflow
3. Comparte el URL o screenshot del error específico
