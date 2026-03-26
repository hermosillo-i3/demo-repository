#!/bin/bash

# Make sure you're starting from develop and it's up to date
git checkout develop
git pull origin develop

# === FEATURE 1 ===
git checkout -b feature/test-squash-1

# Commit 1
echo "\n## [Unreleased]\n- Test feature 1 - commit 1" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 1 part 1"

# Commit 2
echo "- Test feature 1 - commit 2" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 1 part 2"

# Commit 3
echo "- Test feature 1 - commit 3" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 1 part 3"

# Push to remote
git push origin feature/test-squash-1

# === FEATURE 2 ===
git checkout develop
git checkout -b feature/test-squash-2

# Commit 1
echo "\n## [Unreleased]\n- Test feature 2 - commit 1" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 2 part 1"

# Commit 2
echo "- Test feature 2 - commit 2" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 2 part 2"

# Commit 3
echo "- Test feature 2 - commit 3" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 2 part 3"

# Push to remote
git push origin feature/test-squash-2

# === FEATURE 3 ===
git checkout develop
git checkout -b feature/test-squash-3

# Commit 1
echo "\n## [Unreleased]\n- Test feature 3 - commit 1" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 3 part 1"

# Commit 2
echo "- Test feature 3 - commit 2" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 3 part 2"

# Commit 3
echo "- Test feature 3 - commit 3" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "feat: add feature 3 part 3"

# Push to remote
git push origin feature/test-squash-3

# Return to develop
git checkout develop
