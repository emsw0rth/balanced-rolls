# Changelog

## [1.3.0] - 2026-06-14

### Added
- `/br announce` slash command that posts the current modified rolls to raid/party chat (name, raw roll, modifier, adjusted result), deduped so repeated calls only push new rolls

### Changed
- Loot history export is CSV only; format switcher and JSON output removed from the export window

### Removed
- Automatic raid/party chat announcement when a roll is intercepted (use `/br announce` instead)

## [1.2.0] - 2026-05-16

### Added
- Main "Balanced Rolls" window opened from the minimap icon or `/br`, replacing the direct-to-import flow
- "Import Data" button on the main window opens the existing import dialog
- Imported-player list showing Name, Raid-Helper Name, and Roll Modifier (modifier colored green for >1, red for <1)
- `raidHelperName` field on imported player entries
- "Loot History" button on the main window — opens a sortable, exportable history of all loot Gargul has awarded
  - Columns: Date, Player, Item (sortable; click headers to toggle direction)
  - Item links with tooltips on hover
  - Export to JSON or CSV
  - Clear history with confirmation
  - Reads/writes the same `GargulHistoryDB` SavedVariable as the standalone Gargul_History addon, so existing history is preserved

### Changed
- Minimap icon left-click now opens the main window instead of the import window directly
- Imported list automatically refreshes after a successful import

### Removed
- Standalone `Gargul_History` addon (functionality merged into Balanced Rolls — disable or remove the old addon to avoid duplicate award entries)

## [1.1.0] - 2026-03-29

### Added
- Roll type column (MS/OS) in the roll display, ordered as Player | Type | Roll * Mod | Result
- Sorting by roll type priority (MS before OS), then by adjusted roll within each type
- Green highlight for top roller per type group
- Raid/party chat announcement when a roll is intercepted, showing the modifier and adjusted result

### Changed
- UI restyled to match Gargul's dark dialog theme (BACKDROP_DARK_DIALOG_32_32)
- Import window now uses Gargul-style backdrop, close button, gold title, and dark text area
- Roll display uses Gargul-style backdrop and close button positioning
- Buttons changed from GameMenuButtonTemplate to UIPanelButtonTemplate
- Top roller highlight updated to Gargul's success green (0x92FF00)

## [1.0.0] - 2026-03-19

### Added
- Initial release of Balanced Rolls as a Gargul plugin
- Minimap icon with custom dice icon
- Import window for pasting JSON player data (name + roll modifier)
- Data persistence via SavedVariables (clears previous data on re-import)
- Success popup on import completion
- Roll tracking window that hooks into Gargul's roll-off events
- Adjusted roll display showing `roll * modifier = result`, sorted by result
- Class-colored player names and green highlight for top roller
- Automatic anchoring to Gargul's MasterLooterUI loot window
- Positions below GargulGearDisplay when that addon is present
- Matches GargulGearDisplay visual style (tooltip backdrop, close button, draggable title)
- Auto-hides when Gargul's loot window closes
- Slash commands: `/br` and `/balancedrolls`
