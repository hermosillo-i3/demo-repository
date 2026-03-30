# Configuración de GitHub Environments

Este documento explica cómo configurar los environments en GitHub para que funcione el flujo de deploy con aprobación manual.

## ¿Por Qué Usar Environments?

Los GitHub Environments te permiten:
- Controlar quién puede aprobar deploys a producción
- Agregar secrets específicos por ambiente (QAS vs PRD)
- Establecer tiempos de espera mínimos
- Tener visibilidad de qué está desplegado en cada ambiente

## Configuración Paso a Paso

### 1. Acceder a Environments

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (pestaña superior)
3. En el menú lateral izquierdo, busca **Environments**
4. Si no ves la opción, verifica que tu repo sea público o que tengas GitHub Pro/Team/Enterprise

### 2. Crear Environment: QAS

1. Click en **New environment**
2. Nombre: `qas` (exactamente como aparece en el workflow)
3. Click en **Configure environment**
4. **NO agregues protection rules** (queremos que se despliegue automáticamente)
5. Opcional: Puedes agregar variables de ambiente específicas para QAS:
   - Click en "Add variable"
   - Nombre: `SERVER_URL`
   - Valor: `https://qas.example.com`
6. Click en **Save protection rules**

### 3. Crear Environment: Production

1. Click en **New environment**
2. Nombre: `production` (exactamente como aparece en el workflow)
3. Click en **Configure environment**
4. **Activar:** ✅ Required reviewers
5. Click en **Add up to 6 reviewers**
6. Selecciona los usuarios o equipos que pueden aprobar (ej: tú mismo)
7. Opcional pero recomendado:
   - **Wait timer:** 5 minutes (tiempo mínimo antes de poder aprobar)
   - **Allow administrators to bypass:** Desactivar (para mayor seguridad)
8. Opcional: Agregar variables de ambiente para PRD:
   - Nombre: `SERVER_URL`
   - Valor: `https://production.example.com`
9. Click en **Save protection rules**

## Verificar Configuración

Después de configurar, deberías ver:

```
Environments
├── qas
│   └── No protection rules
└── production
    ├── Required reviewers: @tu-usuario
    └── Wait timer: 5 minutes
```

## Cómo Funciona el Flujo con Environments

### Cuando haces push de un tag:

```bash
git push origin 1.0.0
```

### GitHub Actions ejecuta:

1. **Job: deploy-qas** (`environment: qas`)
   - Corre inmediatamente
   - Despliega a QAS
   - ✅ Termina

2. **Job: deploy-prd** (`environment: production`)
   - Necesita que `deploy-qas` termine (`needs: deploy-qas`)
   - **Se PAUSA esperando aprobación**
   - En GitHub Actions verás: "Waiting for approval"
   - Los reviewers reciben notificación

3. **Aprobación Manual**
   - Ve a: Actions → Deploy and Backport → (tu workflow run)
   - Verás un botón amarillo "Review deployments"
   - Click → Selecciona `production` → Approve and deploy
   - Puedes agregar un comentario de aprobación

4. **Job: deploy-prd** (continúa)
   - Después de aprobar, corre el deploy a PRD
   - ✅ Termina

5. **Job: backport-to-develop**
   - Necesita que `deploy-prd` termine (`needs: deploy-prd`)
   - Solo corre si PRD fue exitoso
   - Hace cherry-pick del commit del tag a develop
   - ✅ Termina

## Seguridad y Permisos

### ¿Quién puede aprobar?

Solo los usuarios configurados como "Required reviewers" en el environment `production`.

### ¿Qué pasa si rechazo el deploy?

Si en vez de "Approve" seleccionas "Reject":
- El job `deploy-prd` se cancela
- El job `backport-to-develop` NO se ejecuta (porque depende de PRD)
- El tag queda creado pero sin desplegar a PRD

### ¿Puedo aprobar desde la terminal?

No directamente con `gh`, pero puedes abrir el workflow en el browser:

```bash
# Ver el run actual
gh run view

# Abrir en browser
gh run view --web
```

La aprobación de environments requiere interacción en la UI de GitHub.

## Troubleshooting

### Error: "Environment protection rules not satisfied"

**Causa:** El environment `production` no está configurado o tu usuario no está como reviewer.

**Solución:** Ve a Settings → Environments → production → Agregate como required reviewer.

### Error: "Environment not found: production"

**Causa:** No has creado el environment en GitHub.

**Solución:** Sigue los pasos de "Crear Environment: Production" arriba.

### El workflow se ejecuta pero no espera aprobación

**Causa:** El environment `production` no tiene "Required reviewers" activado.

**Solución:** Edita el environment y activa la protección.

## Secrets por Environment

Si necesitas diferentes credenciales para QAS vs PRD:

### En el Environment QAS:

1. Settings → Environments → qas → Add secret
2. Nombre: `DEPLOY_TOKEN`
3. Valor: `token-de-qas`

### En el Environment Production:

1. Settings → Environments → production → Add secret
2. Nombre: `DEPLOY_TOKEN`
3. Valor: `token-de-prd`

### Usar en el workflow:

```yaml
- name: Deploy
  run: |
    echo "Using token for environment"
  env:
    DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

El secret correcto se usará automáticamente según el environment del job.

## Visualización del Flujo

```
┌─────────────────────────────────────────────────────────┐
│ git push origin 1.0.0                                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Deploy to QAS        │
        │   (Automático)         │
        └───────────┬────────────┘
                    │
                    ▼
        ┌────────────────────────┐
        │  ⏸️ Espera Aprobación  │
        │  Review en GitHub UI   │
        └───────────┬────────────┘
                    │
                    ▼
        ┌────────────────────────┐
        │  Deploy to Production  │
        │  (Después de aprobar)  │
        └───────────┬────────────┘
                    │
                    ▼
        ┌────────────────────────┐
        │  Backport to Develop   │
        │  (Solo si PRD OK)      │
        └────────────────────────┘
```

## Siguiente Paso

Una vez que hayas configurado los environments en GitHub, puedes ejecutar los comandos del archivo `GIT_WORKFLOW_COMMANDS.md` para probar todo el flujo.
