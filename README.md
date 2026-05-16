# Balanced Rolls

A [Gargul](https://github.com/papa-sern/Gargul) plugin for World of Warcraft TBC Anniversary that adjusts roll results based on attendance-weighted modifiers and tracks awarded loot history.

## How it works

1. **Open Balanced Rolls** — Click the minimap icon (dice) or type `/br` to open the main window.
2. **Import player data** — Click **Import Data** and paste a JSON array of players with their roll modifiers. Imported players appear in the list below, showing Name | Raid-Helper Name | Roll Modifier.
3. **Roll on loot** — When the master looter starts a roll via Gargul, Balanced Rolls automatically displays a window showing each roller's result multiplied by their modifier.
4. **Review adjusted results** — The window shows the calculation (`roll * modifier`) and the final adjusted result, sorted highest to lowest.
5. **View loot history** — Click **Loot History** in the main window to see every item Gargul has awarded, sortable by date, player, or item. Exportable to JSON or CSV.

### Example roll display

```
| Player       | Type | Roll * Mod   | Result |
|--------------|------|--------------|--------|
| Nerfdruids   | MS   | 70 * 1.2     | 84     |
| Fitzchiv     | MS   | 100 * 1      | 100    |
| Mehndi       | OS   | 52 * 0.9     | 46.8   |
```

Rolls are sorted by type priority (MS before OS), then by adjusted result within each type. The top roller in each type group is highlighted in green. Each roll is also announced in raid chat with the modifier and adjusted result.

## Import data format

The import expects a JSON array of player objects:

```json
[
  {
    "name": "Mehndi",
    "raidHelperName": "Debrek/Mehndi",
    "rollModifier": "1.2"
  },
  {
    "name": "Blomsterbarn",
    "raidHelperName": "Blomsterbarn",
    "rollModifier": "1.2"
  }
]
```

- `name` — The character name as it appears in-game (used to match rolls)
- `raidHelperName` — The player's identifier in Raid-Helper signups (displayed in the list; optional)
- `rollModifier` — A multiplier applied to the player's roll (e.g. `1.2` = 120%, `0.9` = 90%)

Re-importing replaces all previous player data.

## Loot history

Balanced Rolls listens for Gargul's `ITEM_AWARDED` event and records every awarded item to `GargulHistoryDB`. The Loot History window shows:

- **Date** — When the item was awarded
- **Player** — Who received the item
- **Item** — The item link (hover for tooltip)

Click any column header to sort. Use **Export** to copy the full history as JSON or CSV (`Ctrl+A` then `Ctrl+C`). Use **Clear History** to wipe the log (with confirmation).

> If you previously used the standalone `Gargul_History` addon, your existing history carries over automatically. **Disable or remove the old addon** to avoid recording every award twice.

## Installation

Copy the `Gargul_BalancedRolls` folder into your WoW AddOns directory:

```
World of Warcraft/_anniversary_/Interface/AddOns/Gargul_BalancedRolls/
```

Requires [Gargul](https://github.com/papa-sern/Gargul) to be installed.

## UI Positioning

The Balanced Rolls roll-display window attaches to Gargul's loot distribution window. If [GargulGearDisplay](https://github.com/patrickwlarsen/balanced-rolls) is also installed, it positions itself below it.

## Commands

- `/br` or `/balancedrolls` — Open the main window
- Minimap icon left-click — Open the main window
