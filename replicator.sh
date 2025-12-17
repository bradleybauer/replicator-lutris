#!/bin/bash

# EVE Online UI Settings Replicator (Lutris/Wine Edition)
# Workflow: Auto-detect -> List Profiles (API) -> Select by Name/ID -> Replicate

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Map to store Name->ID associations for the prompt
declare -A CHAR_ID_MAP

# ---------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------

detect_eve_settings() {
  local search_paths=(
    "$HOME/Games/eve-online"
    "$HOME/Games"
    "$HOME/.wine"
    "$HOME/.local/share/lutris"
  )

  for base in "${search_paths[@]}"; do
    if [ -d "$base" ]; then
      local result=$(find "$base" -maxdepth 12 -path "*/AppData/Local/CCP/EVE/*/settings_Default" -type d -print -quit 2>/dev/null)
      if [ -n "$result" ]; then
        echo "$result"
        return 0
      fi
    fi
  done
  return 1
}

get_char_name() {
    local char_id="$1"
    if [[ ! "$char_id" =~ ^[0-9]+$ ]]; then echo ""; return; fi

    if command -v curl &> /dev/null; then
        local response=$(curl -s --max-time 2 "https://esi.evetech.net/latest/characters/$char_id/")
        local name=$(echo "$response" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
        if [ -n "$name" ]; then echo "$name"; else echo "Unknown"; fi
    else
        echo "(curl missing)"
    fi
}

# ---------------------------------------------------------
# Main Script
# ---------------------------------------------------------

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                    🚬  R E P L I C A T O R  🚬${NC}"
echo -e "${YELLOW}                    (Lutris / Wine Edition)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. Detect Settings
echo -e "  ${YELLOW}⚙  Auto-detecting EVE settings directory...${NC}"
SETTINGS_DIR=$(detect_eve_settings)

if [ -z "$SETTINGS_DIR" ]; then
  echo -e "${RED}  ERROR: Could not auto-detect EVE settings directory${NC}"
  echo -n "  > Path: "
  read -r MANUAL_DIR
  if [ -d "$MANUAL_DIR" ]; then SETTINGS_DIR="$MANUAL_DIR"; else exit 1; fi
fi

echo -e "  ${GREEN}✓ Found settings at:${NC}"
echo -e "    $SETTINGS_DIR"
echo ""

# 2. List Profiles (Look up API first)
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  AVAILABLE PROFILES${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Fetching character names from EVE API... please wait.${NC}"
echo ""

printf "  %-15s %-20s %-10s %s\n" "FILE ID" "LAST MODIFIED" "SIZE" "CHARACTER NAME"
echo "  --------------------------------------------------------------------------------"

# Loop through the most recent character files
ls -lt --time-style="+%Y-%m-%d %H:%M" "$SETTINGS_DIR"/core_char_*.dat | grep -v "core_char__.dat" | while read -r line; do
    SIZE=$(echo "$line" | awk '{print $5}')
    DATE=$(echo "$line" | awk '{print $6 " " $7}')
    FILE=$(echo "$line" | awk '{print $8}')
    ID=$(basename "$FILE" | sed 's/core_char_//' | sed 's/.dat//')
    
    # Ensure ID is numeric
    if [[ "$ID" =~ ^[0-9]+$ ]]; then
        # Fetch Name
        REAL_NAME=$(get_char_name "$ID")
        
        # Print Row
        printf "  %-15s %-20s %-10s %b%s%b\n" "$ID" "$DATE" "$SIZE" "$CYAN" "$REAL_NAME" "$NC"
        
        # Save to mapping file for the parent shell to read
        echo "$ID|$REAL_NAME" >> /tmp/eve_replicator_map.tmp
    fi
done

# Read the temporary map back into the associative array
if [ -f /tmp/eve_replicator_map.tmp ]; then
    while IFS="|" read -r id name; do
        # Store lowercase name -> ID
        LOWER_NAME="${name,,}"
        CHAR_ID_MAP["$LOWER_NAME"]="$id"
    done < /tmp/eve_replicator_map.tmp
    rm /tmp/eve_replicator_map.tmp
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${YELLOW}Source Selection${NC}"
echo -e "  Type the ${GREEN}Character Name${NC} (from list above) OR the ${GREEN}File ID${NC}."
echo -n "  > "
read -r INPUT_RAW

# 3. Resolve Input (Name or ID)
INPUT_LOWER="${INPUT_RAW,,}" # Convert input to lowercase
SELECTED_ID=""

# Check if input is a known Name
if [ -n "${CHAR_ID_MAP[$INPUT_LOWER]}" ]; then
    SELECTED_ID="${CHAR_ID_MAP[$INPUT_LOWER]}"
    echo -e "  ${GREEN}✓ Identified Character: $INPUT_RAW (ID: $SELECTED_ID)${NC}"

# Check if input is a direct numeric ID
elif [[ "$INPUT_RAW" =~ ^[0-9]+$ ]] && [ -f "$SETTINGS_DIR/core_char_${INPUT_RAW}.dat" ]; then
    SELECTED_ID="$INPUT_RAW"
    echo -e "  ${GREEN}✓ Identified File ID: $SELECTED_ID${NC}"

else
    echo -e "${RED}  ✗ Error: Input '$INPUT_RAW' not found in the list above or invalid.${NC}"
    echo -e "    Make sure you type the name exactly as shown, or use the ID."
    exit 1
fi

MASTER_CHAR_FILE="$SETTINGS_DIR/core_char_${SELECTED_ID}.dat"

# 4. User File Selection
MASTER_USER_FILE=$(ls -t "$SETTINGS_DIR"/core_user_*.dat 2>/dev/null | grep -v "core_user__.dat" | head -1)
echo -e "  ${GREEN}✓ Using User File:      $(basename "$MASTER_USER_FILE")${NC}"
echo ""

# 5. Confirmation & Execution
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${YELLOW}REPLICATING SETTINGS${NC}"
echo -e "  Copying settings from ${GREEN}$INPUT_RAW${NC} to ALL other characters."
echo ""
echo -n "  Continue? (y/n): "
read -r CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "  Cancelled."
    exit 0
fi

# Backup
BACKUP_DIR="${SETTINGS_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
echo ""
echo -e "  ${YELLOW}⚙  Creating backup...${NC}"
cp -r "$SETTINGS_DIR" "$BACKUP_DIR"
echo -e "     • Backup saved to: $BACKUP_DIR"

echo -e "  ${YELLOW}⚙  Replicating settings...${NC}"

# Copy Chars
for file in "$SETTINGS_DIR"/core_char_*.dat; do
  TARGET_ID=$(basename "$file" | sed 's/core_char_//' | sed 's/.dat//')
  if [[ "$file" != "$MASTER_CHAR_FILE" && "$TARGET_ID" =~ ^[0-9]+$ ]]; then
    cp "$MASTER_CHAR_FILE" "$file"
    echo -e "     • Char: $(basename "$file")"
  fi
done

# Copy Users
for file in "$SETTINGS_DIR"/core_user_*.dat; do
  if [[ "$(basename "$file")" != "core_user__.dat" && "$file" != "$MASTER_USER_FILE" ]]; then
    cp "$MASTER_USER_FILE" "$file"
    echo -e "     • User: $(basename "$file")"
  fi
done

echo ""
echo -e "${GREEN}  ✓ Complete.${NC}"
echo ""
