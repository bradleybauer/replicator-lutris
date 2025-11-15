![Replicator](assets/logogh.png)

# Replicator 🚬

A simple bash script to copy UI settings from one EVE Online character to all your other characters on Linux (Steam/Proton).

## What it does

When you have multiple characters in EVE Online and spend time perfecting your UI layout on one character, this script lets you replicate those settings across all your other characters automatically.

The script copies:
- Character-specific UI settings (window positions, overview layouts, etc.)
- User profile settings

## Requirements

- EVE Online installed via Steam on Linux
- Settings directory at: `~/.local/share/Steam/steamapps/compatdata/8500/pfx/drive_c/users/steamuser/AppData/Local/CCP/EVE/c_ccp_eve_tq_tranquility/settings_Default`

## Usage

1. Make the script executable:
   ```bash
   chmod +x ui-replicator.sh
   ```

2. Run the script:
   ```bash
   ./ui-replicator.sh
   ```

3. Enter the name of the character whose UI settings you want to copy

4. Confirm when prompted

5. The script will:
   - Create a timestamped backup of all your settings
   - Copy the master character's settings to all other characters
   - Display restore instructions in case something goes wrong

## Safety

The script automatically creates a backup before making any changes. If something goes wrong, you can restore from the backup using the commands displayed at the end of the script output.

## Notes

- Make sure to close EVE Online before running this script
- The script identifies your master character by searching for the character name in the settings files
- All existing UI settings for other characters will be overwritten

## License

MIT License - see [LICENSE](LICENSE) file for details.
