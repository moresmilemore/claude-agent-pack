#!/usr/bin/env bash
#
# Portable Project Agent Pack — installer / validator
#
# Run from the project root after unzipping agents.zip:
#     ./install.sh
#
# Verifies the pack layout, validates JSON config, checks MCP prerequisites
# (ImageMagick + uvx + Node),
# offers to install missing pieces, and prints the final activation steps.
#
set -euo pipefail

# ---------- pretty output ----------
BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
ok()    { printf "  ${GREEN}✓${RESET} %s\n" "$1"; }
warn()  { printf "  ${YELLOW}!${RESET} %s\n" "$1"; }
fail()  { printf "  ${RED}✗${RESET} %s\n" "$1"; }
info()  { printf "  ${BLUE}›${RESET} %s\n" "$1"; }
head1() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

# ---------- autodetect project root ----------
# The installer may be launched from anywhere; resolve its own directory and
# cd there so relative paths work regardless of caller cwd.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

printf "${BOLD}Portable Project Agent Pack — Installer${RESET}\n"
printf "${DIM}Deploying into: %s${RESET}\n" "$SCRIPT_DIR"

# ---------- 1. Layout verification ----------
head1 "1. Verifying pack layout"

REQUIRED_FILES=(
  "CLAUDE.md"
  "MEMORY.md"
  ".mcp.json"
  ".claude/settings.json"
  ".claude/agents/orchestrator.md"
  ".claude/agents/architect.md"
  ".claude/agents/reviewer.md"
  ".claude/agents/planner.md"
  ".claude/agents/explorer.md"
  ".claude/agents/coder.md"
  ".claude/agents/debugger.md"
  ".claude/agents/test-engineer.md"
  ".claude/agents/photo.md"
  ".claude/agents/researcher.md"
  ".claude/rules/code-style.md"
  ".claude/rules/testing.md"
  ".claude/rules/ui-style.md"
  ".claude/rules/security.md"
  ".claude/rules/LESSONS.md"
)

missing=0
for f in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    ok "$f"
  else
    fail "missing: $f"
    missing=$((missing + 1))
  fi
done

if (( missing > 0 )); then
  fail "$missing required file(s) are missing. Re-unzip agents.zip and rerun."
  exit 1
fi

# ---------- 1b. JSON validation ----------
head1 "1b. Validating JSON configuration"

if command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool .claude/settings.json >/dev/null
  ok ".claude/settings.json is valid JSON"
  python3 -m json.tool .mcp.json >/dev/null
  ok ".mcp.json is valid JSON"
else
  warn "python3 not found — skipping JSON syntax validation for .claude/settings.json and .mcp.json"
fi

# ---------- 2. Frontmatter invariants ----------
head1 "2. Validating agent frontmatter"

invariant_fail=0
for agent in .claude/agents/*.md; do
  name=$(basename "$agent" .md)
  if ! grep -q "^memory: project$" "$agent"; then
    fail "$name is missing 'memory: project'"
    invariant_fail=$((invariant_fail + 1))
  fi
  if ! grep -q "type: adaptive" "$agent"; then
    fail "$name is missing 'thinking: {type: adaptive}'"
    invariant_fail=$((invariant_fail + 1))
  fi
done

if (( invariant_fail == 0 )); then
  ok "all 10 agents declare memory: project + adaptive thinking"
else
  fail "$invariant_fail frontmatter invariant(s) violated"
  exit 1
fi

# ---------- 2b. Runtime settings invariants ----------
head1 "2b. Validating Claude Code runtime settings"

settings_fail=0
if grep -q '"agent"[[:space:]]*:[[:space:]]*"orchestrator"' .claude/settings.json; then
  ok ".claude/settings.json sets orchestrator as the default main-thread agent"
else
  fail ".claude/settings.json is missing 'agent: orchestrator'"
  settings_fail=$((settings_fail + 1))
fi

for pattern in \
  'Read(./.env)' \
  'Read(./node_modules/**)' \
  'Read(./.cache/**)' \
  'Read(./.venv/**)' \
  'Read(./venv/**)'; do
  if grep -Fq "$pattern" .claude/settings.json; then
    ok ".claude/settings.json excludes $pattern"
  else
    warn ".claude/settings.json does not exclude $pattern"
  fi
done

if (( settings_fail > 0 )); then
  fail "$settings_fail Claude Code runtime invariant(s) violated"
  exit 1
fi

# ---------- 3. Prerequisite check ----------
head1 "3. Checking MCP prerequisites"

need_imagemagick=0
need_uvx=0
need_node=0

if command -v magick >/dev/null 2>&1; then
  ver=$(magick -version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
  ok "ImageMagick present (${ver})  → photo agent ready"
elif command -v convert >/dev/null 2>&1; then
  warn "ImageMagick 6 'convert' detected — the photo agent prefers ImageMagick 7 'magick'"
else
  fail "ImageMagick not found  → photo agent will not function"
  need_imagemagick=1
fi

if command -v uvx >/dev/null 2>&1; then
  ok "uvx present  → ImageMagick MCP launcher ready"
else
  fail "uvx not found  → photo agent's MCP server will not launch"
  need_uvx=1
fi

if command -v node >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
  node_ver=$(node --version 2>/dev/null)
  ok "Node ${node_ver} + npx present  → researcher agent (Playwright) ready on first run"
else
  fail "Node / npx not found  → researcher agent's browser MCP will not function"
  need_node=1
fi

# ---------- 4. Offer to install missing prerequisites ----------
if (( need_imagemagick == 1 || need_uvx == 1 || need_node == 1 )); then
  head1 "4. Installing missing prerequisites (optional)"

  # Detect package manager
  PKG_MGR=""
  PKG_INSTALL=""
  if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    PKG_MGR="brew"
    PKG_INSTALL="brew install"
  elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
    PKG_INSTALL="sudo apt-get install -y"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
    PKG_INSTALL="sudo dnf install -y"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
  fi

  if [[ -z "$PKG_MGR" ]]; then
    warn "No known package manager (brew/apt/dnf/pacman) detected."
    warn "Install missing prerequisites manually, then rerun ./install.sh"
  else
    info "Detected package manager: ${PKG_MGR}"
    read -r -p "  Install missing prerequisites now? [y/N] " ans
    if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
      if (( need_imagemagick == 1 )); then
        info "Installing imagemagick..."
        $PKG_INSTALL imagemagick || warn "imagemagick install failed — install manually"
      fi
      if (( need_uvx == 1 )); then
        info "Installing uv..."
        $PKG_INSTALL uv || warn "uv install failed — install manually"
      fi
      if (( need_node == 1 )); then
        info "Installing node..."
        $PKG_INSTALL node || $PKG_INSTALL nodejs || warn "node install failed — install manually"
      fi
    else
      warn "Skipped. Install the prerequisites before using the photo or researcher agents."
    fi
  fi
else
  head1 "4. Prerequisites satisfied"
  ok "nothing to install"
fi

# ---------- 5. Summary ----------
head1 "5. Deployment summary"
printf "  ${GREEN}%s${RESET}\n" "Pack is installed at: $SCRIPT_DIR"
printf "  ${GREEN}%s${RESET}\n" "Agents: 10 specialists (memory: project, adaptive thinking)"
printf "  ${GREEN}%s${RESET}\n" "Rules:  5 modular load-on-demand files"
printf "  ${GREEN}%s${RESET}\n" "Memory: CLAUDE.md (permanent) + MEMORY.md (pointer index)"
printf "  ${GREEN}%s${RESET}\n" "Runtime: orchestrator is the default main-thread Claude Code agent"
printf "  ${GREEN}%s${RESET}\n" "MCP:    .mcp.json configured for ImageMagick (uvx) + Playwright"

head1 "Next steps"
info "Restart Claude Code in this directory so it loads .mcp.json and the new agents"
info "The orchestrator is already configured as the default main-thread agent in .claude/settings.json"
info "Single-shot tasks can call a specialist directly (e.g. @coder, @photo, @researcher)"
info "Fill in project-specific stack + conventions at the bottom of CLAUDE.md"

printf "\n${GREEN}${BOLD}Done.${RESET}\n\n"
