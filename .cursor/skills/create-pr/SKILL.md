---
name: create-pr
description: Create pull requests with automatic change summaries, CHANGELOG.md updates, and version bumping for feature, release, and hotfix branches. Use when the user asks to create a PR, submit changes, prepare a pull request, or create a new release.
---

# Create Pull Request

This skill automates PR creation by analyzing changes, updating the changelog, bumping versions for hotfixes, and creating the PR via gh cli.

## Quick Reference

| Branch Type | Base Branch | PR Target | Pull Latest | Update CHANGELOG | Bump Version | Update package.json | Confirmation |
|-------------|-------------|-----------|-------------|------------------|--------------|---------------------|--------------|
| `feature/**` | `develop` | `develop` | ✓ Yes | ✓ Yes | ✗ No | ✗ No | ✓ Yes |
| `release/**` | `develop` | **`main`** | ✓ Yes | ✓ Version + date | ✓ Yes (middle +1, last→0) | ✓ Yes | ✓ Yes |
| `hotfix/**` | `main` | `main` | ✓ Yes | ✓ Yes | ✓ Yes (patch) | ✓ Yes | ✓ Yes |
| Other | `main` | `main` | ✓ Yes | ✓ Yes | ✗ No | ✗ No | ✓ Yes |

## Entry Points

**"Create a new release" / "Create release"** (user is NOT on a release branch):
- Create the release branch from scratch, then run the full release workflow. No need for the user to create the branch manually.

**"Create PR" / "Submit changes"** (user is on feature, hotfix, release, or other branch):
- Run the standard workflow for that branch type.

## Workflow

### Step 0: Create Release Branch (only when user asks "create a new release" and is NOT on release/**)

When the user asks to create a new release and the current branch does NOT start with `release/`:

1. **If there are uncommitted changes**: Ask user to commit or stash them first; creating the release branch will switch away from the current branch.
2. Read package.json to get current version (e.g. 8.7.4)
3. Compute new version: **middle number +1, last number → 0** (e.g. 8.7.4 → 8.8.0). Never add 1 to the last number—that is for hotfixes.
4. Fetch and create branch from develop:
   ```bash
   git fetch origin develop
   git checkout -b release/[NEW_VERSION] origin/develop
   ```
   Example: `git checkout -b release/8.8.0 origin/develop`
5. Continue to Step 1 (you are now on the release branch). The CHANGELOG in develop should already have the release content prepared; we will only update the version heading and date.

### Step 1: Analyze the Current Branch

First, get the current branch name:
```bash
git branch --show-current
```

Determine the base branch to compare against by checking the branch name pattern:
- If branch starts with `feature/` or `release/` → compare with `develop`
- If branch starts with `hotfix/` → compare with `main`
- Otherwise (any other branch name) → compare with `main`

### Step 2: Pull Latest Changes from Base Branch

**CRITICAL:** Pull latest changes from the base branch to ensure accurate version bumping and avoid conflicts.

1. Fetch latest from remote:
```bash
git fetch origin [BASE_BRANCH]
```

2. Attempt to merge the base branch into current branch:
```bash
git merge origin/[BASE_BRANCH]
```

3. Check for merge conflicts:
   - **If merge is clean:** Continue to next step
   - **If there are conflicts:** 
     - Run `git status` to show conflicted files
     - Inform the user: "There are merge conflicts with [BASE_BRANCH]. Please resolve the conflicts manually and run the create-pr command again."
     - Stop the workflow and wait for user to resolve conflicts

### Step 3: Analyze Changes

Run in parallel (using the determined base branch):
```bash
git status
git diff origin/[BASE_BRANCH]...HEAD
git log origin/[BASE_BRANCH]...HEAD --oneline
```

Determine:
- Current branch name and type (feature vs hotfix)
- Base branch for comparison
- List of changed files
- Commit history since diverging from base branch

### Step 4: Categorize Changes

Analyze all changes and group them by category:
- **[NEW]**: New features, endpoints, models, or capabilities
- **[UPDATE]**: Improvements, enhancements, refactors, or modifications to existing functionality
- **[FIX]**: Bug fixes, error corrections, or issue resolutions

### Step 5: Update CHANGELOG.md and Version

**Always update CHANGELOG.md (behavior depends on branch type):**

1. Read package.json to get current version
2. Get current date in format: `Month Day, Year` (e.g., `Feb 26, 2026`)

**For `release/**` branches (changelog content already prepared):**
- The CHANGELOG content for the release is already in place. Update the **version heading** and **date** of the topmost block: (1) replace the first `# X.Y.Z` heading with `# [NEW_VERSION]` (e.g. `# 8.8.0`); (2) replace the `Date: ...` line with `Date: [CURRENT_DATE]`. Do not add new entries or change the bullet content from the diff.
- Bump version in package.json: **middle number +1, last number → 0** (e.g., 8.7.4 → 8.8.0). Never increment the last number—that is for hotfixes. Update package.json with this new version.

**For `hotfix/**` branches:**
- Determine version: Bump patch (e.g., 7.103.0 → 7.103.1)
- Add new entry at the top of CHANGELOG.md (see block below), then update package.json to the bumped version.

**For `feature/**` or other branches:**
- Use current version as-is (no bump). Add new entry at the top of CHANGELOG.md (see block below). Do not modify package.json.

**New CHANGELOG entry format** (used for feature, hotfix, and other; not for release):

```markdown
# [VERSION]
Date: [CURRENT_DATE]
* [NEW]
  * New feature 1
* [UPDATE]
  * Enhancement 1
* [FIX]
  * Fix 1
```

Format rules:
- Version on line by itself: `# 7.103.1`
- Date on next line: `Date: Feb 26, 2026`
- Bullet sections: `* [NEW]`, `* [UPDATE]`, `* [FIX]`
- Sub-bullets indented with two spaces: `  * Item description`
- Keep descriptions concise and specific
- Only include sections that have changes (omit empty sections)

**Update package.json version:**
- **release/** branches: Set version to middle +1, last → 0 (e.g. 8.7.4 → 8.8.0). Never add 1 to the last number.
- **hotfix/** branches: Set version to bumped patch (e.g. 7.103.0 → 7.103.1)
- **feature/** or other: Do not modify package.json

### Step 6: Prepare PR Summary and Request Confirmation

Create a structured PR description:

```markdown
## Summary
- Brief bullet point summary of changes
- Focus on what changed and why
- Include 2-5 key points

## Changes by Category
### [NEW]
- New feature or capability 1
- New feature or capability 2

### [UPDATE]
- Enhancement 1
- Enhancement 2

### [FIX]
- Bug fix 1
- Bug fix 2

## Version
[If release/**] Version bumped from X.Y.Z to X.(Y+1).0 (minor release)
[If hotfix/**] Version bumped from X.Y.Z to X.Y.(Z+1)
[If feature/** or other] Using current version X.Y.Z (no bump)

## Test Plan
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No breaking changes
```

**Request User Confirmation:**

Present the following information to the user and ask for confirmation using the AskQuestion tool:

```
Ready to create PR with the following changes:

Branch: [BRANCH_NAME] → [BASE_BRANCH]
Type: [feature/release/hotfix/other]

Changes to be committed:
- CHANGELOG.md (updated with [VERSION] [or for release: version heading + date])
[If release or hotfix]- package.json (version bumped to [NEW_VERSION])

PR Title: [TITLE]

Categorized Changes:
[NEW]
- Item 1
- Item 2

[UPDATE]
- Item 1
- Item 2

[FIX]
- Item 1
- Item 2

Proceed with creating the PR?
```

Use AskQuestion with options: ["Yes, create the PR", "No, cancel"]

- **If user selects "Yes"**: Continue to Step 7
- **If user selects "No"**: Stop workflow and inform user that PR creation was cancelled

### Step 7: Commit Changes and Create the PR

1. Commit the updated files:
   - **For release/** or **hotfix/** branches: Commit both CHANGELOG.md and package.json
   ```bash
   git add CHANGELOG.md package.json && git commit -m "Update changelog and version for [NEW_VERSION]"
   ```
   - **For feature/** or other branches: Commit only CHANGELOG.md
   ```bash
   git add CHANGELOG.md && git commit -m "Update changelog"
   ```

2. Push branch to remote:
```bash
git push -u origin HEAD
```

3. Create PR using gh cli with the prepared summary:
   - **For release/** branches: PR targets `main` (use `--base main`)
   ```bash
   gh pr create --base main --title "[Release] X.Y.0" --body "$(cat <<'EOF'
   [PR Summary from Step 4]
   EOF
   )"
   ```
   - **For feature/** branches: PR targets `develop` (use `--base develop`)
   - **For hotfix/** or other: PR targets `main` (default, or use `--base main`)

4. Return the PR URL to the user

### Step 8: Notify Team on Slack (release branches only, optional)

**Only for `release/**` branches.** After the PR is created, ask the user if they want to send a Slack message requesting the team to review:

Use AskQuestion with options: ["Yes, send Slack message", "No, skip"]

**If user selects "Yes":**

1. Use `slack_search_channels` (MCP tool: `plugin-slack-slack`) to find the channel ID for **#mexicali**.
2. Send the message using `slack_send_message` (MCP tool: `plugin-slack-slack`) with this template:

```
Equipo, se encuentra abierto un release, por favor revisen en el servidor de QAS sus cambios y pongan su check :white_check_mark: en este mensaje, gracias
```

3. Return the Slack message link to the user.

**If the Slack MCP server is not available:**
- Inform the user: "The Slack MCP server (`plugin-slack-slack`) is not enabled. To enable it, go to Cursor Settings > MCP and add the Slack MCP server. Once enabled, run the release flow again or send the message manually to #mexicali."

**If user selects "No":** Skip this step.

## PR Title Format

Choose an appropriate title based on the branch type and changes:
- For `release/**` branches: `[Release] X.Y.0` or `[Release] Brief description (X.Y.0)`
- For `hotfix/**` branches: `[Hotfix] Brief description of the fix`
- For `feature/**` branches: `[Feature] Brief description of the feature`
- For other branches with updates: `[Update] Brief description of the changes`
- For other branches with fixes: `[Fix] Brief description of the bug fixed`

## Important Notes

- **Pull latest changes FIRST**: Always pull latest changes from base branch before proceeding to ensure accurate version bumping
- **CHANGELOG.md**: Always update for all branches. For **release/** update the version heading and date of the existing top entry (content stays as-is); for feature/hotfix/other add a new entry from the diff
- **package.json version**: Update for `release/**` (middle +1, last→0, e.g. 8.7.4→8.8.0) and `hotfix/**` (last +1, e.g. 8.7.4→8.7.5). Do not update for feature or other
- **Base branch comparison**:
  - `feature/**` and `release/**` branches → compare with `origin/develop`, merge `origin/develop` into current branch to stay up to date
  - `hotfix/**` branches → compare with `origin/main`
  - Other branches → compare with `origin/main`
- **PR target**: Release PRs merge into `main` (not develop). Feature PRs merge into `develop`. Hotfix and other merge into `main`.
- **Merge conflicts**: If conflicts occur when pulling base branch, stop and ask user to resolve manually
- **User confirmation**: Always ask for confirmation before committing and creating the PR
- **Commit changes**: Always commit CHANGELOG.md (and package.json for release/hotfix) before creating the PR
- **Use git status before and after** to ensure changes are properly committed
- **Changelog format**: Follow the existing format exactly - version as heading, date line, bullet sections

## Error Handling

- **If gh cli is not available**: Inform user to install gh cli or create PR manually
- **If branch is not pushed**: Push it before creating PR
- **If there are uncommitted changes**: Ask user whether to commit them first
- **If CHANGELOG.md doesn't exist**: Create it with the proper header before adding entries
- **If base branch doesn't exist locally**: Fetch it first with `git fetch origin [BASE_BRANCH]`
- **If branch name doesn't match feature/**, **release/**, or **hotfix/**: Default to comparing with `origin/main`
- **If merge conflicts occur**: Stop the workflow, show conflicted files, and instruct user to resolve conflicts manually before running create-pr again
- **If user cancels confirmation**: Stop workflow and do not create PR

## Example Execution

### Example 1: Hotfix Branch

For branch `hotfix/fix-user-authentication`:

1. Detect branch type: `hotfix/**` ✓
2. Base branch: `main`
3. Pull latest from `origin/main` (no conflicts) ✓
4. Analyze changes: Fixed auth token validation bug
5. Categorize: [FIX] - Fix auth token validation
6. Bump version: 7.103.0 → 7.103.1
7. Update CHANGELOG.md with version 7.103.1
8. Update package.json version to 7.103.1
9. Show confirmation to user → User confirms ✓
10. Commit: `git add CHANGELOG.md package.json && git commit -m "Update changelog and version for 7.103.1"`
11. Push: `git push -u origin HEAD`
12. Create PR with title: `[Hotfix] Fix user authentication token validation`

### Example 2: Feature Branch

For branch `feature/add-payment-integration`:

1. Detect branch type: `feature/**` ✓
2. Base branch: `develop`
3. Pull latest from `origin/develop` (no conflicts) ✓
4. Analyze changes: Added new payment gateway integration
5. Categorize: [NEW] - Add payment gateway integration
6. Use current version: 7.103.0 (no bump)
7. Update CHANGELOG.md with version 7.103.0
8. Do NOT update package.json
9. Show confirmation to user → User confirms ✓
10. Commit: `git add CHANGELOG.md && git commit -m "Update changelog for payment integration"`
11. Push: `git push -u origin HEAD`
12. Create PR with title: `[Feature] Add payment gateway integration`

### Example 3: Release Branch (create from scratch)

User says "create a new release" and is on `develop`:

1. Step 0: Read package.json (8.7.4) → new version 8.8.0 (middle +1, last → 0)
2. Create branch: `git checkout -b release/8.8.0 origin/develop`
3. Detect branch type: `release/**` ✓
4. Base branch: `develop`
5. Pull latest from `origin/develop` and merge into current branch (no conflicts) ✓
6. CHANGELOG already has the release content; update the version heading to `# 8.8.0` and the `Date:` line to today
7. Bump version in package.json: 8.7.4 → 8.8.0 (middle +1, last → 0)
8. Show confirmation to user → User confirms ✓
9. Commit: `git add CHANGELOG.md package.json && git commit -m "Update changelog and version for 8.8.0"`
10. Push: `git push -u origin HEAD`
11. Create PR with `--base main` and title: `[Release] 8.8.0`
12. Ask user: "Do you want to notify the team on Slack?" → User confirms ✓
13. Send message to #mexicali: "Equipo, se encuentra abierto un release, por favor revisen en el servidor de QAS sus cambios y pongan su check :white_check_mark: en este mensaje, gracias"

### Example 4: Merge Conflict Scenario

For branch `hotfix/critical-fix`:

1. Detect branch type: `hotfix/**` ✓
2. Base branch: `main`
3. Pull latest from `origin/main` → **MERGE CONFLICTS** ❌
4. Show conflicted files to user
5. Stop workflow with message: "There are merge conflicts with main. Please resolve the conflicts manually and run the create-pr command again."
6. User resolves conflicts, commits, then runs `/create-pr` again
