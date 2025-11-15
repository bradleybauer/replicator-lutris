![Replicator](assets/logogh.png)

# Replicator 🚬

A simple bash script to copy UI settings from one EVE Online character to all your other characters on Linux (Steam/Proton).

[Illuminated is recruiting!](https://www.illuminatedcorp.com)

## What it does

When you have multiple characters in EVE Online and spend time perfecting your UI layout on one character, this script lets you replicate those settings across all your other characters automatically.

The script copies:
- Character-specific UI settings (window positions, overview layouts, etc.)
- User profile settings

## Requirements

- EVE Online installed via Steam on Linux
- You have launched EVE at least once (to create settings files)

The script automatically detects your EVE settings directory from common Steam/Proton locations.

## Usage

1. Make the script executable:
   ```bash
   chmod +x replicator.sh
   ```

2. Run the script:
   ```bash
   ./replicator.sh
   ```

3. The script will auto-detect your EVE settings directory

4. Enter the name of the character whose UI settings you want to copy

5. Confirm when prompted

6. The script will:
   - Create a timestamped backup of all your settings
   - Copy the master character's settings to all other characters
   - Display restore instructions in case something goes wrong

## Safety

The script automatically creates a backup before making any changes. If something goes wrong, you can restore from the backup using the commands displayed at the end of the script output.

## Auto-Detection

The script automatically searches for your EVE settings in multiple locations to support different Steam and EVE installation methods:

**Steam base directories checked:**
- `~/.local/share/Steam`
- `~/.steam/steam`
- `~/.steam`

**EVE installation patterns supported:**
- Standalone CCP launcher installations
- Steam-managed EVE installations
- Various Proton prefix configurations

If the script cannot find your settings directory, it will display the locations it checked and provide helpful troubleshooting tips.

## Notes

- Make sure to close EVE Online before running this script
- The script identifies your master character by searching for the character name in the settings files
- All existing UI settings for other characters will be overwritten

## License

MIT License - see [LICENSE](LICENSE) file for details.
