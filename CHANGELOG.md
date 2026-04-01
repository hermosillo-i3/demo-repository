# 1.2.0
Date: March 27, 2026
* [NEW]
  * Skill de Cursor (`create-pr`) para crear PRs con resumen, changelog y versionado por tipo de rama
  * Job `assign-reviewer` que asigna el revisor solicitado vía API de GitHub
  * Verificación de sincronización main/develop contra microservicios en el workflow de asignación de revisores
* [UPDATE]
  * Workflow `assign_reviewer_to_pull_request`: flujo `select-reviewer` → `assign-reviewer`, Slack con rama objetivo, autor del PR y bloque opcional de advertencias de microservicios
  * PR hacia `develop`: `feature/test-assign-reviewer-to-pr`

v 1.0.3
* [NEW]
    * YUE testing
    * YUE testing\n## [Unreleased]\n- Test feature 1 - commit 1
- Test feature 1 - commit 2
- Test feature 1 - commit 3
\n## [Unreleased]\n- Test feature 2 - commit 1
- Test feature 2 - commit 2
- Test feature 2 - commit 3
