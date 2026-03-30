# Welcome to your organization's demo respository
This code repository (or "repo") is designed to demonstrate the best GitHub has to offer with the least amount of noise.

The repo includes an `index.html` file (so it can render a web page), GitHub Actions workflows, and a CSS stylesheet dependency.

## Git Workflow Documentation

Este repositorio implementa un flujo de trabajo basado en Git con `develop` como rama principal.

### 🚀 Empezar Aquí

- **[QUICKSTART.md](QUICKSTART.md)** - Guía rápida para empezar en 5 minutos

### 📚 Documentación Completa

- **[GIT_WORKFLOW_COMMANDS.md](GIT_WORKFLOW_COMMANDS.md)** - Todos los comandos para features, releases y hotfixes
- **[SCRIPTS_USAGE.md](SCRIPTS_USAGE.md)** - Guía detallada de los scripts automatizados
- **[GITHUB_ENVIRONMENTS_SETUP.md](GITHUB_ENVIRONMENTS_SETUP.md)** - Configuración de environments (requerido)

### 🛠️ Scripts Automatizados

- **`create-release.sh`** - Crea release con incremento patch (1.0.0 → 1.0.1)
- **`create-hotfix.sh`** - Crea hotfix con incremento minor (1.0.5 → 1.1.0)

### ⚙️ GitHub Actions

- **`.github/workflows/backport-hotfix.yml`** - Deploy automático: QAS → PRD (aprobación) → Backport
