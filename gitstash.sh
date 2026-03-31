#!/bin/bash

# 1. Get the name of the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 2. Define the target branch (usually develop or main)
TARGET_BRANCH=${1:-develop}

echo "Starting auto-squash of $CURRENT_BRANCH against $TARGET_BRANCH..."

# 3. Soft reset to the point where the branch diverged from target
# This keeps all your changes staged but removes the individual commits
git reset --soft $(git merge-base $TARGET_BRANCH $CURRENT_BRANCH)

# 4. Check if there are changes to commit
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes found to squash."
    exit 0
fi

# 5. Commit everything with a single message
# You can change the message here or let it prompt you
echo "Enter the final commit message:"
read -r COMMIT_MSG
git commit -m "$COMMIT_MSG"

echo "✅ Success! Branch $CURRENT_BRANCH now has exactly 1 commit."
echo "Next step: git push origin $CURRENT_BRANCH --force-with-lease"