#!/bin/bash
# save-and-push.sh — One-command save & push for beginners.
# Run from inside your project folder: bash save-and-push.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $*"; }
success() { echo -e "${GREEN}✔${NC}  $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
fail()    { echo -e "${RED}✖${NC}  $*"; exit 1; }

# ─── Checks ─────────────────────────────────────────────────────────────────

if ! command -v git &>/dev/null; then
    fail "git is not installed. Run github-quickstart.sh first."
fi

# ─── Find the project ───────────────────────────────────────────────────────

if [[ ! -d .git ]]; then
    echo ""
    info "This folder ($(pwd)) doesn't look like a git project."
    echo ""
    echo -en "${BOLD}Where is your project folder?${NC} (drag the folder here or type the path): "
    read -r project_path

    # Strip quotes that macOS drag-and-drop sometimes adds
    project_path="${project_path%\'}"
    project_path="${project_path#\'}"
    project_path="${project_path%\"}"
    project_path="${project_path#\"}"
    # Trim trailing spaces from drag-and-drop
    project_path="${project_path%% }"

    if [[ -z "$project_path" ]]; then
        fail "No path entered."
    fi

    if [[ ! -d "$project_path" ]]; then
        fail "\"$project_path\" is not a folder. Check the path and try again."
    fi

    cd "$project_path"

    if [[ ! -d .git ]]; then
        fail "\"$project_path\" exists but isn't a git project. Run github-quickstart.sh on it first."
    fi

    success "Using project: $PWD"
fi

if ! git remote get-url origin &>/dev/null; then
    fail "No GitHub remote found. Run github-quickstart.sh first to connect this project."
fi

# ─── Show what changed ──────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${CYAN}── Save & Push ──${NC}"
echo ""

CHANGES="$(git status --short)"

if [[ -z "$CHANGES" ]]; then
    success "Nothing has changed since your last save. You're all caught up!"
    echo ""
    exit 0
fi

echo -e "${BOLD}Files that changed:${NC}"
echo ""

while IFS= read -r line; do
    code="${line:0:2}"
    file="${line:3}"
    case "$code" in
        "??") echo -e "  ${GREEN}+ (new)${NC}      $file" ;;
        " D"|"D ") echo -e "  ${RED}- (deleted)${NC}  $file" ;;
        *)    echo -e "  ${YELLOW}~ (changed)${NC}  $file" ;;
    esac
done <<< "$CHANGES"

echo ""

# ─── Confirm ─────────────────────────────────────────────────────────────────

echo -en "${BOLD}Do you want to save and push all of these?${NC} (Y/n): "
read -r confirm
confirm="${confirm:-y}"

if [[ ! "$confirm" =~ ^[Yy] ]]; then
    info "Cancelled. Nothing was saved."
    echo ""
    exit 0
fi

# ─── Commit message ─────────────────────────────────────────────────────────

echo ""
echo -en "${BOLD}Briefly, what did you change?${NC} (e.g. \"added login page\"): "
read -r message

if [[ -z "$message" ]]; then
    message="Update project — $(date '+%b %d, %Y %I:%M %p')"
    info "No message given, using: \"$message\""
fi

# ─── Stage, commit, push ────────────────────────────────────────────────────

echo ""
info "Saving your changes..."
git add -A
git commit -m "$message"

info "Pushing to GitHub..."
if git push 2>&1; then
    echo ""
    success "Done! Your changes are on GitHub."
    echo ""
    REPO_URL="$(git remote get-url origin | sed 's/\.git$//')"
    echo -e "  ${BOLD}See it here:${NC} ${CYAN}${REPO_URL}${NC}"
    echo ""
else
    echo ""
    fail "Push failed. This usually means someone else pushed changes first."
    echo "  Try running: ${CYAN}git pull --rebase && git push${NC}"
    echo ""
fi
