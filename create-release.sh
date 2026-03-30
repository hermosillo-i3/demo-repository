#!/bin/bash

# Script para crear release automáticamente
# Uso: ./create-release.sh [patch|minor|major]
# Ejemplo: ./create-release.sh patch  (1.0.0 → 1.0.1)

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que estamos en develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo -e "${RED}❌ Error: Debes estar en la rama develop${NC}"
    echo "Ejecuta: git checkout develop"
    exit 1
fi

# Verificar que develop está limpio
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ Error: Hay cambios sin commitear${NC}"
    echo "Ejecuta: git status"
    exit 1
fi

# Actualizar develop
echo -e "${YELLOW}📥 Actualizando develop desde remoto...${NC}"
git pull origin develop

# Obtener el último tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
echo -e "${GREEN}📌 Último tag: ${LAST_TAG}${NC}"

# Parsear la versión
IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_TAG"

# Determinar tipo de incremento
INCREMENT_TYPE=${1:-patch}

case $INCREMENT_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}❌ Error: Tipo inválido. Usa: patch, minor o major${NC}"
        exit 1
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo -e "${GREEN}🆕 Nueva versión: ${NEW_VERSION}${NC}"

# Confirmar con usuario
read -p "¿Crear release ${NEW_VERSION}? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Cancelado${NC}"
    exit 0
fi

# Actualizar package.json
echo -e "${YELLOW}📝 Actualizando package.json...${NC}"
npm version $NEW_VERSION --no-git-tag-version

# Hacer commit del cambio de versión
echo -e "${YELLOW}💾 Creando commit...${NC}"
git add package.json
git commit -m "chore: bump version to ${NEW_VERSION}"

# Crear tag
echo -e "${YELLOW}🏷️  Creando tag ${NEW_VERSION}...${NC}"
git tag -a $NEW_VERSION -m "Release ${NEW_VERSION}"

# Push del commit y tag
echo -e "${YELLOW}🚀 Haciendo push a develop y tag...${NC}"
git push origin develop
git push origin $NEW_VERSION

echo -e "${GREEN}✅ Release ${NEW_VERSION} creado exitosamente!${NC}"
echo -e "${GREEN}🎯 El workflow de deploy se disparó automáticamente.${NC}"
echo -e "${YELLOW}👉 Verifica en: https://github.com/$(git config --get remote.origin.url | sed 's/.*:\(.*\)\.git/\1/')/actions${NC}"
