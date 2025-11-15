#!/bin/bash

# EVE Online UI Settings Copy Script
# Copies UI settings from one character to all others

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# EVE settings directory
SETTINGS_DIR="$HOME/.local/share/Steam/steamapps/compatdata/8500/pfx/drive_c/users/steamuser/AppData/Local/CCP/EVE/c_ccp_eve_tq_tranquility/settings_Default"

# Check if settings directory exists
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${RED}Error: EVE settings directory not found at:${NC}"
    echo "$SETTINGS_DIR"
    exit 1
fi

# Get master character name from user
echo -e "${YELLOW}Enter the name of the character whose UI you want to copy:${NC}"
read -r MASTER_CHAR_NAME

# Find the character file containing this name
echo -e "${YELLOW}Searching for character '$MASTER_CHAR_NAME'...${NC}"
MASTER_USER_FILE=$(grep -il "$MASTER_CHAR_NAME" "$SETTINGS_DIR"/core_user_*.dat 2>/dev/null | head -1)

if [ -z "$MASTER_USER_FILE" ]; then
    echo -e "${RED}Error: Could not find character '$MASTER_CHAR_NAME' in settings files${NC}"
    exit 1
fi

# Extract the user ID from the filename
MASTER_USER_ID=$(basename "$MASTER_USER_FILE" | sed 's/core_user_//' | sed 's/.dat//')
echo -e "${GREEN}Found character in: $MASTER_USER_FILE${NC}"
echo -e "${GREEN}User ID: $MASTER_USER_ID${NC}"

# Find all character files and pick the most recently modified one for this user
# (This is a heuristic - we assume the character file with the same general timing)
# For a more accurate match, we look for the largest character file as it likely has the most settings
MASTER_CHAR_FILE=$(ls -lS "$SETTINGS_DIR"/core_char_*.dat 2>/dev/null | grep -v "core_char__" | head -1 | awk '{print $NF}')

if [ -z "$MASTER_CHAR_FILE" ]; then
    echo -e "${RED}Error: Could not find character settings file${NC}"
    exit 1
fi

echo -e "${GREEN}Using character file: $MASTER_CHAR_FILE${NC}"

# Confirm with user
echo -e "${YELLOW}This will copy settings from:${NC}"
echo "  Character file: $(basename "$MASTER_CHAR_FILE")"
echo "  User file: $(basename "$MASTER_USER_FILE")"
echo -e "${YELLOW}To ALL other characters. Continue? (y/n)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

# Create backup
BACKUP_DIR="${SETTINGS_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}Creating backup at: $BACKUP_DIR${NC}"
cp -r "$SETTINGS_DIR" "$BACKUP_DIR"
echo -e "${GREEN}Backup created${NC}"

# Copy character settings to all other characters
echo -e "${YELLOW}Copying character settings...${NC}"
CHAR_COUNT=0
for file in "$SETTINGS_DIR"/core_char_*.dat; do
    if [[ "$file" != *"core_char__.dat" && "$file" != "$MASTER_CHAR_FILE" ]]; then
        cp "$MASTER_CHAR_FILE" "$file"
        echo "  Copied to $(basename "$file")"
        ((CHAR_COUNT++))
    fi
done

# Copy user settings to all other users
echo -e "${YELLOW}Copying user settings...${NC}"
USER_COUNT=0
for file in "$SETTINGS_DIR"/core_user_*.dat; do
    if [[ "$file" != *"core_user__.dat" && "$file" != "$MASTER_USER_FILE" ]]; then
        cp "$MASTER_USER_FILE" "$file"
        echo "  Copied to $(basename "$file")"
        ((USER_COUNT++))
    fi
done

echo ""
echo -e "${GREEN}=== COMPLETE ===${NC}"
echo -e "${GREEN}Copied settings to $CHAR_COUNT characters and $USER_COUNT user profiles${NC}"
echo -e "${GREEN}Backup saved at: $BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}Launch EVE and test your characters. If something went wrong,${NC}"
echo -e "${YELLOW}restore from backup:${NC}"
echo "  rm -rf \"$SETTINGS_DIR\""
echo "  mv \"$BACKUP_DIR\" \"$SETTINGS_DIR\""
