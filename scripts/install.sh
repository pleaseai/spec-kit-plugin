#!/usr/bin/env bash
# Spec-Kit Plugin Installation Script
# Copies .specify directory to project root if it doesn't exist

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the plugin root directory
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Get the project root directory (where Claude Code is running)
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  Spec-Kit Plugin Installation${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""
echo -e "${BLUE}Plugin Root:${NC}  $PLUGIN_ROOT"
echo -e "${BLUE}Project Root:${NC} $PROJECT_ROOT"
echo ""

# Source directory (where .specify is in the plugin)
SOURCE_SPECIFY="$PLUGIN_ROOT/.specify"
TARGET_SPECIFY="$PROJECT_ROOT/.specify"

# Check if source .specify directory exists
if [[ ! -d "$SOURCE_SPECIFY" ]]; then
    echo -e "${RED}[X] Error: Plugin .specify directory not found at: $SOURCE_SPECIFY${NC}"
    echo -e "${YELLOW}  The plugin may not be installed correctly.${NC}"
    exit 1
fi

# Check if target .specify already exists
if [[ -d "$TARGET_SPECIFY" ]]; then
    echo -e "${GREEN}[OK] .specify directory already exists in project${NC}"
    echo -e "${YELLOW}  Skipping installation to preserve existing configuration${NC}"
    echo ""
    echo -e "${BLUE}Location:${NC} $TARGET_SPECIFY"
    echo ""
    echo -e "${BLUE}To reinstall:${NC}"
    echo -e "  1. Backup your existing .specify directory"
    echo -e "  2. Remove it: ${YELLOW}rm -rf $TARGET_SPECIFY${NC}"
    echo -e "  3. Re-run this script"
    echo ""
    exit 0
fi

# Copy .specify directory to project root
echo -e "${BLUE}Installing .specify directory...${NC}"
echo ""

if cp -r "$SOURCE_SPECIFY" "$TARGET_SPECIFY"; then
    echo -e "${GREEN}[OK] Successfully installed .specify directory${NC}"
    echo ""

    # Make scripts executable
    if [[ -d "$TARGET_SPECIFY/scripts/bash" ]]; then
        chmod +x "$TARGET_SPECIFY/scripts/bash"/*.sh 2>/dev/null || true
        echo -e "${GREEN}[OK] Made bash scripts executable${NC}"
    fi

    # Display installed structure
    echo ""
    echo -e "${BLUE}Installed structure:${NC}"
    echo ""
    echo "  .specify/"
    echo "  +-- templates/          # Specification templates"
    echo "  |   +-- spec-template.md"
    echo "  |   +-- plan-template.md"
    echo "  |   +-- tasks-template.md"
    echo "  |   +-- checklist-template.md"
    echo "  |   +-- agent-file-template.md"
    echo "  +-- memory/"
    echo "  |   +-- constitution.md # Project principles"
    echo "  +-- scripts/"
    echo "      +-- bash/            # Automation scripts"
    echo "          +-- create-new-feature.sh"
    echo "          +-- setup-plan.sh"
    echo "          +-- check-prerequisites.sh"
    echo "          +-- update-agent-context.sh"
    echo "          +-- common.sh"
    echo ""

    # Check if specs directory exists, create if not
    SPECS_DIR="$PROJECT_ROOT/specs"
    if [[ ! -d "$SPECS_DIR" ]]; then
        mkdir -p "$SPECS_DIR"
        echo -e "${GREEN}[OK] Created specs/ directory for feature documentation${NC}"
        echo ""
    fi

    echo -e "${BLUE}================================================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo ""
    echo -e "  1. ${BLUE}Create your project constitution:${NC}"
    echo -e "     ${YELLOW}/speckit.constitution${NC}"
    echo ""
    echo -e "  2. ${BLUE}Start your first feature:${NC}"
    echo -e "     ${YELLOW}/speckit.specify${NC} Your feature description here"
    echo ""
    echo -e "  3. ${BLUE}Follow the workflow:${NC}"
    echo -e "     - Specify -> Plan -> Tasks -> Implement"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo -e "  - README: $PLUGIN_ROOT/README.md"
    echo -e "  - Templates: $TARGET_SPECIFY/templates/"
    echo -e "  - Constitution: $TARGET_SPECIFY/memory/constitution.md"
    echo ""

else
    echo -e "${RED}[X] Failed to install .specify directory${NC}"
    echo -e "${YELLOW}  Please check permissions and try again${NC}"
    exit 1
fi