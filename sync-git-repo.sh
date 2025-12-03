#!/bin/bash

# Script to safely sync git repo main branch while preserving current state
set -euo pipefail

# Parameters
REPO_NAME="${1:-dd-source}"
MAIN_BRANCH="${2:-main}"

REPO_DIR="$HOME/dd/$REPO_NAME"
SCRIPT_NAME="$(basename "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$SCRIPT_NAME]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$SCRIPT_NAME WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[$SCRIPT_NAME ERROR]${NC} $1"
    exit 1
}

# Check if repository directory exists
if [[ ! -d "$REPO_DIR" ]]; then
    error "$REPO_NAME directory not found at $REPO_DIR"
fi

# Change to repository directory
cd "$REPO_DIR" || error "Failed to change to $REPO_DIR"

log "Working in $(pwd)"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository"
fi

# Store original directory for cleanup
ORIGINAL_DIR="$OLDPWD"

# Cleanup function
cleanup() {
    if [[ -n "${ORIGINAL_DIR:-}" ]]; then
        cd "$ORIGINAL_DIR"
    fi
}
trap cleanup EXIT

# Check for ongoing operations
if [[ -f ".git/MERGE_HEAD" ]]; then
    error "Merge in progress. Please resolve merge conflicts first."
fi

if [[ -f ".git/REBASE_HEAD" ]] || [[ -d ".git/rebase-merge" ]] || [[ -d ".git/rebase-apply" ]]; then
    error "Rebase in progress. Please complete or abort rebase first."
fi

if [[ -f ".git/CHERRY_PICK_HEAD" ]]; then
    error "Cherry-pick in progress. Please complete or abort cherry-pick first."
fi

# Store current state
CURRENT_BRANCH=$(git branch --show-current)
CURRENT_COMMIT=$(git rev-parse HEAD)

log "Current branch: $CURRENT_BRANCH"
log "Current commit: $CURRENT_COMMIT"

# Check for uncommitted changes
HAS_STAGED_CHANGES=false
HAS_UNSTAGED_CHANGES=false

if ! git diff --cached --quiet; then
    HAS_STAGED_CHANGES=true
fi

if ! git diff --quiet; then
    HAS_UNSTAGED_CHANGES=true
fi

# Store uncommitted changes if they exist
STASH_CREATED=false
if [[ "$HAS_STAGED_CHANGES" == true ]] || [[ "$HAS_UNSTAGED_CHANGES" == true ]]; then
    STASH_MESSAGE="Auto-stash by $SCRIPT_NAME on $(date)"
    git stash push -m "$STASH_MESSAGE"
    STASH_CREATED=true
    log "Stashed uncommitted changes"
fi

# Function to restore state
restore_state() {
    log "Restoring original state..."
    
    # Switch back to original branch if we're not on it
    if [[ "$(git branch --show-current)" != "$CURRENT_BRANCH" ]]; then
        git checkout "$CURRENT_BRANCH" 2>/dev/null || {
            warn "Could not switch back to $CURRENT_BRANCH, staying on current branch"
        }
    fi
    
    # Restore stashed changes if we created a stash
    if [[ "$STASH_CREATED" == true ]]; then
        if [[ -n "$(git stash list)" ]]; then
            git stash pop
            log "Restored stashed changes"
        else
            warn "No stashes found, changes may have been lost"
        fi
    fi
}

# Set up error handling to restore state
trap 'restore_state; exit 1' ERR

# Switch to main branch
log "Switching to $MAIN_BRANCH branch..."
git checkout "$MAIN_BRANCH"

# Pull latest changes
log "Pulling latest changes from origin/$MAIN_BRANCH..."
if git pull origin "$MAIN_BRANCH"; then
    log "Successfully updated $MAIN_BRANCH branch"
else
    error "Failed to pull from origin/$MAIN_BRANCH"
fi

# Restore original state
restore_state

log "Script completed successfully!"
log "$MAIN_BRANCH branch has been updated and your original state has been restored"
