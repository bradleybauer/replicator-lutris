#!/bin/bash

# EVE Online UI Settings Copy Script
# Copies UI settings from one character to all others

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to auto-detect EVE settings directory
detect_eve_settings() {
  # Possible Steam base directories
  local base_paths=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.steam"
  )

  # Possible EVE installation path patterns
  local eve_paths=(
    "c_ccp_eve_tq_tranquility"
    "c_programfiles(x86)_steam_steamapps_eve_tq_tranquility"
    "c_program_files_x86_ccp_eve_tq_tranquility"
    "c_programfiles_x86_ccp_eve_tq_tranquility"
  )

  # Try each combination
  for base in "${base_paths[@]}"; do
    for eve_path in "${eve_paths[@]}"; do
      local full_path="$base/steamapps/compatdata/8500/pfx/drive_c/users/steamuser/AppData/Local/CCP/EVE/$eve_path/settings_Default"
      if [ -d "$full_path" ]; then
        echo "$full_path"
        return 0
      fi
    done
  done

  return 1
}

# Auto-detect EVE settings directory
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                    🚬  R E P L I C A T O R  🚬${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}⚙  Auto-detecting EVE settings directory...${NC}"
SETTINGS_DIR=$(detect_eve_settings)

# Check if settings directory was found
if [ -z "$SETTINGS_DIR" ]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}  ERROR: Could not auto-detect EVE settings directory${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${YELLOW}  Checked the following locations:${NC}"
  echo ""
  echo "    • ~/.local/share/Steam/steamapps/compatdata/8500/.../settings_Default"
  echo "    • ~/.steam/steam/steamapps/compatdata/8500/.../settings_Default"
  echo "    • ~/.steam/steamapps/compatdata/8500/.../settings_Default"
  echo ""
  echo -e "${YELLOW}  Please ensure:${NC}"
  echo ""
  echo "    1. EVE Online is installed via Steam"
  echo "    2. You have launched EVE at least once (to create settings)"
  echo "    3. Steam is using the default Proton prefix for EVE (AppID 8500)"
  echo ""
  exit 1
fi

echo -e "  ${GREEN}✓ Found settings at:${NC}"
echo -e "    $SETTINGS_DIR"
echo ""

# Get master character name from user
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Master Character Selection${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Enter the name of the character whose UI you want to copy:${NC}"
echo -n "  > "
read -r MASTER_CHAR_NAME

# Find the character file containing this name
echo ""
echo -e "  ${YELLOW}⚙  Searching for character '$MASTER_CHAR_NAME'...${NC}"
MASTER_USER_FILE=$(grep -il "$MASTER_CHAR_NAME" "$SETTINGS_DIR"/core_user_*.dat 2>/dev/null | head -1)

if [ -z "$MASTER_USER_FILE" ]; then
  echo ""
  echo -e "  ${RED}✗ Error: Could not find character '$MASTER_CHAR_NAME' in settings files${NC}"
  echo ""
  exit 1
fi

# Extract the user ID from the filename
MASTER_USER_ID=$(basename "$MASTER_USER_FILE" | sed 's/core_user_//' | sed 's/.dat//')
echo -e "  ${GREEN}✓ Found character: $MASTER_CHAR_NAME${NC}"
echo -e "    User ID: $MASTER_USER_ID"
echo ""

# Find all character files and pick the most recently modified one for this user
# (This is a heuristic - we assume the character file with the same general timing)
# For a more accurate match, we look for the largest character file as it likely has the most settings
MASTER_CHAR_FILE=$(ls -lS "$SETTINGS_DIR"/core_char_*.dat 2>/dev/null | grep -v "core_char__" | head -1 | awk '{print $NF}')

if [ -z "$MASTER_CHAR_FILE" ]; then
  echo -e "  ${RED}✗ Error: Could not find character settings file${NC}"
  echo ""
  exit 1
fi

echo -e "  ${GREEN}✓ Using character file: $(basename "$MASTER_CHAR_FILE")${NC}"
echo ""

# Confirm with user
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Confirmation${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}This will copy settings from:${NC}"
echo -e "    • Character file: $(basename "$MASTER_CHAR_FILE")"
echo -e "    • User file: $(basename "$MASTER_USER_FILE")"
echo ""
echo -e "  ${YELLOW}To ALL other characters on this installation.${NC}"
echo ""
echo -e -n "  ${YELLOW}Continue? (y/n):${NC} "
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo ""
  echo -e "  ${YELLOW}Operation cancelled.${NC}"
  echo ""
  exit 0
fi

# Create backup
BACKUP_DIR="${SETTINGS_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Backing Up & Replicating Settings${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}⚙  Creating backup...${NC}"
cp -r "$SETTINGS_DIR" "$BACKUP_DIR"
echo -e "  ${GREEN}✓ Backup created${NC}"
echo ""

# Copy character settings to all other characters
echo -e "  ${YELLOW}⚙  Copying character settings...${NC}"
CHAR_COUNT=0
for file in "$SETTINGS_DIR"/core_char_*.dat; do
  if [[ "$file" != *"core_char__.dat" && "$file" != "$MASTER_CHAR_FILE" ]]; then
    cp "$MASTER_CHAR_FILE" "$file"
    echo -e "     • $(basename "$file")"
    ((CHAR_COUNT++))
  fi
done

# Copy user settings to all other users
echo ""
echo -e "  ${YELLOW}⚙  Copying user settings...${NC}"
USER_COUNT=0
for file in "$SETTINGS_DIR"/core_user_*.dat; do
  if [[ "$file" != *"core_user__.dat" && "$file" != "$MASTER_USER_FILE" ]]; then
    cp "$MASTER_USER_FILE" "$file"
    echo -e "     • $(basename "$file")"
    ((USER_COUNT++))
  fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                  🚬  REPLICATION COMPLETE  🚬${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}  ✓ Settings copied to:${NC}"
echo -e "    • $CHAR_COUNT character profiles"
echo -e "    • $USER_COUNT user profiles"
echo ""
echo -e "${GREEN}  ✓ Backup created at:${NC}"
echo -e "    $BACKUP_DIR"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Next Steps:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  1. Launch EVE Online and test your characters"
echo -e "  2. If something went wrong, restore from backup:"
echo ""
echo -e "     ${YELLOW}rm -rf \"$SETTINGS_DIR\"${NC}"
echo -e "     ${YELLOW}mv \"$BACKUP_DIR\" \"$SETTINGS_DIR\"${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${RED}Illuminated is recruiting - https://www.illuminatedcorp.com${NC}"
echo ""
