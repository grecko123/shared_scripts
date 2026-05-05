#!/bin/bash
# github-quickstart.sh — Interactive script to init a git repo and push it to GitHub.
# Designed for macOS. Run with: bash github-quickstart.sh

set -euo pipefail

# ─── Colors & helpers ────────────────────────────────────────────────────────

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
fail()    { echo -e "${RED}✖${NC}  $*"; }
header()  { echo -e "\n${BOLD}${CYAN}── $* ──${NC}\n"; }

ask() {
    local prompt="$1" var="$2" default="${3:-}"
    if [[ -n "$default" ]]; then
        echo -en "${BOLD}$prompt${NC} [${default}]: "
    else
        echo -en "${BOLD}$prompt${NC}: "
    fi
    read -r input
    eval "$var=\"\${input:-$default}\""
}

ask_yn() {
    local prompt="$1" default="${2:-y}"
    local hint="Y/n"
    [[ "$default" == "n" ]] && hint="y/N"
    echo -en "${BOLD}$prompt${NC} ($hint): "
    read -r answer
    answer="${answer:-$default}"
    [[ "$answer" =~ ^[Yy] ]]
}

pause() {
    echo -en "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# ─── Welcome ─────────────────────────────────────────────────────────────────

clear
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║          GitHub Quickstart for macOS                 ║"
echo "║                                                      ║"
echo "║  This script will walk you through:                  ║"
echo "║    1. Installing prerequisites (git, GitHub CLI)     ║"
echo "║    2. Authenticating with GitHub                     ║"
echo "║    3. Initializing a git repository                  ║"
echo "║    4. Creating a GitHub repo (public or private)     ║"
echo "║    5. Pushing your first commit                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
pause

# ─── Step 1: Xcode Command Line Tools ───────────────────────────────────────

header "Step 1 / 5 — Checking prerequisites"

if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed."
else
    warn "Xcode Command Line Tools not found. This includes git."
    info "A system dialog may appear asking you to install them."
    info "Click \"Install\" and wait for it to finish (can take a few minutes)."
    echo ""
    xcode-select --install 2>/dev/null || true
    echo ""
    warn "Waiting for installation to complete..."
    echo "  (If the dialog didn't appear, you may already have them.)"
    echo ""
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    success "Xcode Command Line Tools installed."
fi

if command -v git &>/dev/null; then
    success "git is available ($(git --version))."
else
    fail "git is still not available after installing Xcode tools."
    fail "Please restart your terminal and run this script again."
    exit 1
fi

# ─── Step 2: Homebrew & GitHub CLI ───────────────────────────────────────────

header "Step 2 / 5 — GitHub CLI (gh)"

if command -v gh &>/dev/null; then
    success "GitHub CLI already installed ($(gh --version | head -1))."
else
    info "The GitHub CLI makes it easy to create repos and log in."
    info "We'll install it via Homebrew (the macOS package manager)."
    echo ""

    if ! command -v brew &>/dev/null; then
        info "Homebrew not found — installing it first..."
        info "You may be prompted for your macOS password."
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo ""
            warn "Homebrew was installed to /opt/homebrew."
            info "To make it permanent, add this line to your ~/.zshrc:"
            echo -e "  ${CYAN}eval \"\$(/opt/homebrew/bin/brew shellenv)\"${NC}"
            echo ""
        fi
        success "Homebrew installed."
    else
        success "Homebrew already installed."
    fi

    info "Installing GitHub CLI..."
    brew install gh
    success "GitHub CLI installed."
fi

# ─── Step 3: GitHub Authentication ───────────────────────────────────────────

header "Step 3 / 5 — Authenticating with GitHub"

if gh auth status &>/dev/null; then
    success "Already logged into GitHub."
    gh auth status
else
    echo "You need a GitHub account to continue."
    echo ""
    if ask_yn "Do you already have a GitHub account?"; then
        info "Great! Let's log you in."
    else
        echo ""
        echo -e "${BOLD}Let's create one:${NC}"
        echo "  1. Open ${CYAN}https://github.com/signup${NC} in your browser"
        echo "  2. Follow the prompts to create a free account"
        echo "  3. Verify your email address"
        echo "  4. Come back here when you're done"
        echo ""
        if command -v open &>/dev/null; then
            if ask_yn "Open github.com/signup in your browser now?"; then
                open "https://github.com/signup"
            fi
        fi
        pause
    fi

    echo ""
    info "Logging in via the GitHub CLI..."
    info "This will open your browser for a secure login."
    echo ""
    gh auth login --web --git-protocol https
    echo ""
    success "Authenticated with GitHub."
fi

# Set git identity if not already configured
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    echo ""
    info "Git needs your name and email for commits."
    ask "Your name (for git commits)" GIT_NAME
    git config --global user.name "$GIT_NAME"
fi

if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    ask "Your email (for git commits)" GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi

success "Git identity: $(git config --global user.name) <$(git config --global user.email)>"

# ─── Step 4: Initialize the repository ──────────────────────────────────────

header "Step 4 / 5 — Initialize a git repository"

echo "Where is the project you want to put on GitHub?"
echo ""
echo "  1) I already have a folder with my files"
echo "  2) I want to create a new, empty project"
echo ""
echo -en "${BOLD}Choice${NC} (1/2): "
read -r dir_choice

if [[ "$dir_choice" == "2" ]]; then
    echo ""
    ask "What do you want to call the project?" PROJECT_DIR
    PROJECT_DIR="${HOME}/${PROJECT_DIR}"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    success "Created new project folder: $PWD"
else
    echo ""
    echo "  Drag your project folder from Finder into this window,"
    echo "  or type the path (e.g. ~/Desktop/my-project)."
    echo ""
    echo -en "${BOLD}Project folder${NC}: "
    read -r project_path

    # Strip quotes and trailing spaces from drag-and-drop
    project_path="${project_path%\'}"
    project_path="${project_path#\'}"
    project_path="${project_path%\"}"
    project_path="${project_path#\"}"
    project_path="${project_path%% }"

    # Expand ~ if they typed it
    project_path="${project_path/#\~/$HOME}"

    if [[ -z "$project_path" ]]; then
        fail "No path entered."
        exit 1
    fi

    if [[ ! -d "$project_path" ]]; then
        fail "\"$project_path\" doesn't exist or isn't a folder. Check the path and try again."
        exit 1
    fi

    cd "$project_path"
    success "Using project folder: $PWD"
fi

if [[ -d .git ]]; then
    warn "This directory is already a git repository."
    if ! ask_yn "Continue with the existing repo?" "y"; then
        echo "Exiting. cd into a different directory and try again."
        exit 0
    fi
else
    git init
    success "Initialized git repository in $PWD"
fi

# ─── .gitignore ──────────────────────────────────────────────────────────────

if [[ ! -f .gitignore ]]; then
    echo ""
    info "Let's set up a .gitignore so you don't commit junk files."
    echo ""
    echo "  Pick a template (or skip):"
    echo ""
    echo "    1) General (macOS + editors)  — good default"
    echo "    2) Python"
    echo "    3) Node.js / JavaScript"
    echo "    4) Swift / Xcode"
    echo "    5) None — I'll make my own"
    echo ""
    echo -en "${BOLD}Choice${NC} [1]: "
    read -r ignore_choice
    ignore_choice="${ignore_choice:-1}"

    case "$ignore_choice" in
        1)
            cat > .gitignore << 'GITIGNORE'
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

# Editors
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local
GITIGNORE
            success "Created .gitignore (general)."
            ;;
        2)
            cat > .gitignore << 'GITIGNORE'
# macOS
.DS_Store
._*

# Python
__pycache__/
*.py[cod]
*$py.class
*.egg-info/
dist/
build/
.eggs/
*.egg
.venv/
venv/
env/
.env
.env.local

# Editors
.vscode/
.idea/
*.swp
*~

# Jupyter
.ipynb_checkpoints/
GITIGNORE
            success "Created .gitignore (Python)."
            ;;
        3)
            cat > .gitignore << 'GITIGNORE'
# macOS
.DS_Store
._*

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/releases

# Build
dist/
build/
*.tsbuildinfo

# Environment
.env
.env.local
.env.*.local

# Editors
.vscode/
.idea/
*.swp
*~
GITIGNORE
            success "Created .gitignore (Node.js)."
            ;;
        4)
            cat > .gitignore << 'GITIGNORE'
# macOS
.DS_Store
._*

# Xcode
build/
DerivedData/
*.xcuserstate
*.xcworkspace
!*.xcworkspace/contents.xcworkspacedata
xcuserdata/
*.moved-aside
*.pbxuser
!default.pbxuser
*.perspectivev3
!default.perspectivev3

# Swift Package Manager
.build/
Packages/
Package.resolved

# CocoaPods
Pods/
GITIGNORE
            success "Created .gitignore (Swift/Xcode)."
            ;;
        5)
            info "Skipping .gitignore."
            ;;
    esac
fi

# ─── Initial commit ─────────────────────────────────────────────────────────

if [[ -z "$(git log --oneline 2>/dev/null | head -1)" ]]; then
    # No commits yet — create one
    if [[ ! -f README.md ]]; then
        REPO_NAME="$(basename "$PWD")"
        echo "# $REPO_NAME" > README.md
        success "Created README.md"
    fi

    git add -A
    git commit -m "Initial commit"
    success "Created initial commit."
else
    info "Repository already has commits — skipping initial commit."
fi

# ─── Step 5: Create GitHub repo & push ───────────────────────────────────────

header "Step 5 / 5 — Create GitHub repository & push"

REPO_NAME_DEFAULT="$(basename "$PWD")"
ask "Repository name on GitHub" REPO_NAME "$REPO_NAME_DEFAULT"

echo ""
echo "  Visibility:"
echo "    1) ${GREEN}Private${NC} — only you (and people you invite) can see it"
echo "    2) Public  — anyone on the internet can see it"
echo ""
echo -en "${BOLD}Choice${NC} [1]: "
read -r vis_choice
vis_choice="${vis_choice:-1}"

VISIBILITY="private"
[[ "$vis_choice" == "2" ]] && VISIBILITY="public"

echo ""
ask "Short description (optional)" REPO_DESC ""

echo ""
info "Creating ${VISIBILITY} repo: ${CYAN}$REPO_NAME${NC} on GitHub..."
echo ""

GH_FLAGS="--${VISIBILITY} --source=. --push"
if [[ -n "$REPO_DESC" ]]; then
    gh repo create "$REPO_NAME" $GH_FLAGS --description "$REPO_DESC"
else
    gh repo create "$REPO_NAME" $GH_FLAGS
fi

# ─── Done! ───────────────────────────────────────────────────────────────────

REPO_URL="$(gh repo view --json url -q .url 2>/dev/null || echo "")"

echo ""
echo -e "${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║                    All done! 🎉                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${BOLD}Local repo:${NC}  $PWD"
if [[ -n "$REPO_URL" ]]; then
    echo -e "  ${BOLD}GitHub URL:${NC}  ${CYAN}$REPO_URL${NC}"
fi
echo -e "  ${BOLD}Visibility:${NC}  $VISIBILITY"
echo ""
echo -e "${BOLD}What's next:${NC}"
echo "  • Edit files, then commit changes:"
echo -e "      ${CYAN}git add -A && git commit -m \"your message\"${NC}"
echo "  • Push to GitHub:"
echo -e "      ${CYAN}git push${NC}"
echo "  • Invite collaborators (private repos):"
echo -e "      ${CYAN}gh repo edit --add-collaborator USERNAME${NC}"
echo "  • Open the repo in your browser:"
echo -e "      ${CYAN}gh repo view --web${NC}"
echo ""
