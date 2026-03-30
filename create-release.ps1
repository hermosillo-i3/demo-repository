# Script PowerShell para crear release automáticamente
# Uso: .\create-release.ps1 -Type patch|minor|major
# Ejemplo: .\create-release.ps1 -Type patch  (1.0.0 → 1.0.1)

param(
    [Parameter(Position=0)]
    [ValidateSet("patch", "minor", "major")]
    [string]$Type = "patch"
)

$ErrorActionPreference = "Stop"

# Verificar que estamos en develop
$currentBranch = git branch --show-current
if ($currentBranch -ne "develop") {
    Write-Host "❌ Error: Debes estar en la rama develop" -ForegroundColor Red
    Write-Host "Ejecuta: git checkout develop" -ForegroundColor Yellow
    exit 1
}

# Verificar que develop está limpio
$status = git status --porcelain
if ($status) {
    Write-Host "❌ Error: Hay cambios sin commitear" -ForegroundColor Red
    Write-Host "Ejecuta: git status" -ForegroundColor Yellow
    exit 1
}

# Actualizar develop
Write-Host "📥 Actualizando develop desde remoto..." -ForegroundColor Yellow
git pull origin develop

# Obtener el último tag
$lastTag = git describe --tags --abbrev=0 2>$null
if (-not $lastTag) {
    $lastTag = "0.0.0"
}
Write-Host "📌 Último tag: $lastTag" -ForegroundColor Green

# Parsear la versión
$parts = $lastTag.Split('.')
$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2]

# Incrementar según tipo
switch ($Type) {
    "major" {
        $major++
        $minor = 0
        $patch = 0
    }
    "minor" {
        $minor++
        $patch = 0
    }
    "patch" {
        $patch++
    }
}

$newVersion = "$major.$minor.$patch"
Write-Host "🆕 Nueva versión: $newVersion" -ForegroundColor Green

# Confirmar con usuario
$confirm = Read-Host "¿Crear release $newVersion? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "❌ Cancelado" -ForegroundColor Yellow
    exit 0
}

# Actualizar package.json
Write-Host "📝 Actualizando package.json..." -ForegroundColor Yellow
npm version $newVersion --no-git-tag-version

# Hacer commit del cambio de versión
Write-Host "💾 Creando commit..." -ForegroundColor Yellow
git add package.json
git commit -m "chore: bump version to $newVersion"

# Crear tag
Write-Host "🏷️  Creando tag $newVersion..." -ForegroundColor Yellow
git tag -a $newVersion -m "Release $newVersion"

# Push del commit y tag
Write-Host "🚀 Haciendo push a develop y tag..." -ForegroundColor Yellow
git push origin develop
git push origin $newVersion

Write-Host "✅ Release $newVersion creado exitosamente!" -ForegroundColor Green
Write-Host "🎯 El workflow de deploy se disparó automáticamente." -ForegroundColor Green

# Obtener la URL del repo
$repoUrl = git config --get remote.origin.url
if ($repoUrl -match "github.com[:/](.+?)(.git)?$") {
    $repoPath = $matches[1] -replace '\.git$', ''
    Write-Host "👉 Verifica en: https://github.com/$repoPath/actions" -ForegroundColor Yellow
}
