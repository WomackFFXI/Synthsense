# SynthSense (v2.6)

**SynthSense** is a lightweight, real-time synthesis tracker addon for Windower 4 in *Final Fantasy XI* 

It automatically detects crafting results directly from game packets, tracking successes, high-quality tiers (HQ1, HQ2, HQ3), and breaks. 
It features a customizable, draggable on-screen display that persists your statistics and screen position across sessions.

---

## Features

- **Accurate Packet Tracking:** Listens to incoming `0x06F` packets for instant, reliable detection of NQ, HQ, 
	and break results—even when using automated crafting tools like `craft`.
	
- **Manual Adjustments:** Add or Subtract counts from any category on the fly without resetting or manually editing configuration files.
								
- **Detailed Statistics:** Tracks total synths, individual tier totals, individual percentages, and your overall HQ success rate.

- **Color-Coded UI:** Clean, color-coded text box for quick readability at a glance.

- **Click-and-Drag UI:** Easily reposition the display anywhere on your screen.

- **Persistent Storage:** Automatically saves your location and statistical counters to `data/settings.xml` upon unloading, 
   zoning, logging out, or issuing a save command.

---

## Installation

1. Create a folder named `synthsense` inside your Windower 4 addons directory:
   ```text
   C:\Program Files (x86)\Windower4\addons\synthsense\
   ```
2. Place `synthsense.lua` into that folder.
3. In-game, load the addon using:
   '''text
   //lua load synthsense
	'''

---

## Commands

You can use either `//synthsense` or the short alias `//ss`:

| Command | Description |
| :--- | :--- |
| `//ss reset` *(or `//ss r`)* | Resets all recorded synth counters and totals back to zero. |
| `//ss save` | Manually saves current statistics and window coordinates to `settings.xml`. |
| `//ss toggle` | Toggles the visibility of the on-screen display box. |
| `//ss show` | Forces the UI text box to display. |
| `//ss hide` | Hides the UI text box. |
| `//ss add <cat> [amount] *(Or `//ss a`)* | Adds or subtracts counts from a category(nq, hq1, hq2, hq3, break). Defaults to 1. 

---
Manual Adjustment examples:
* add 1 NQ: //ss add nq
* add 10 NQs: //ss add nq 10
* add 5 HQ1: //ss add hq1 5
* add 2 break: //ss add break 2
*subtract/fix error: //ss add nq -1 or //ss add break -2
**Use Negative Numbers to subtract from Counts**

---

## On-Screen Display Overview

The tracker box displays real-time statistics in the following layout:

```text
  === SYNTH SENSE ===
Breaks:    0 (  0.0%)
NQ:        0 (  0.0%)
HQ1:       0 (  0.0%)
HQ2:       0 (  0.0%)
HQ3:       0 (  0.0%)
-----------------------
Total Synths: 0
Total HQ Rate: 0.0%
```

---

## Configuration & Data

Your settings and cumulative stats are stored in `addons/synthsense/data/settings.xml`. 
If you ever wish to manually edit your saved coordinates or statistics outside of the game, you can modify that XML file while the addon is unloaded.
