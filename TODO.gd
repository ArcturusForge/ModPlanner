# This is purely a TODO list and has no function other than to keep notes
# --- Completed
# -/ Fix bug for cancel on the game select window directly activating the opening menu.
# -/ Create the choice field prefab.
# -/ Design extra's field script template.
# -/ Generate the extra's fields in ModAddDriver.
# -/ Save popup
# -/ Edit a mod. Rewrite the modEditDriver script to handle pre-existing data.
# -/ Rework mod names into an extra's field instead. ->OR convert scan function into plugin script.
# -/ Design game extension plugin script template.
# -/ Have a hyperlink feature to link to mod download locations.
# -/ Create a mod list scan feature that checks for compatibility/required mods.
# -/ Create an "open all links" button to rapidly open all linked mods in a browser.
# -/ Track when mod list needs to be scanned for compatibility due to edits.
# -/ Sorting options based on which column header is clicked.
# -/ ModTreeManager: open tooltip with options.
# -/ ModTreeManager: Add delete mod tooltip option.
# -/ ModTreeManager: Add open mod link tooltip option.
# -/ Add a copy link shortcut button to mod dl hyperlink.
# -/ Allow for mod importing to skip manual inputing of mod data.
# -/ URGENT!!! MainManager: Rework how mods apply edits to themselves.
# -/ Deleting mods breaks mod refs to their modlist index.
# -/ Add an auto assign load order feature.
# -/ Figure out a way to pin overwrite-able fix mods to the top of load orders.
# -/ Add custom assign effects based on type of mod. Engine tweaks should always place at -1 in LO.
# -/ Add mod import feature that detects already included mods.
# -/ Add a reload extension option.
# -/ Add a compatible mods field that takes in the name & link & an option of "Do Overwrite" or "Get Overwritten".
# -?Solved by compatibility field? Add soft requirement toggle in mod edit required fields.
# -/ Add the copy mod name option to mod menu.
# -/ Add export mod option to mod menu.
# -/ Add select/deselect all option to mod import window.
# -/ Detect duplicated mods in modlist during scan.
# -/ Add an "open save location" menu option.
# -/ Add an option to mods extra's fields with options "Choose from list" or "Custom". For required/incom/compa fields.
# -/ Display general session info in the preview panel.
# -/ Have a general description field in the preview panel.
# -/ An "adjust load order" mod-option: Array.Inserts mod at a position in the load order.
# -/ Track game version for session.
# -/ Have the category display an up or down arrow or nothing based on the current sorting of mods
# -/ Add mod double-click to edit.
# -/ Mod search bar.
# -/ Have a video resources section in the preview panel.
# -/ Add open/copy vid link buttons next to vid links in the preview panel.
# -/ Have the extension reload feature reload the actual extension file as well.
# -?Is this possible:Turns out the answer is yes? Create a one-line mod exporter/importer feature that compresses a mod entry into a copy&paste-able line
# -/ Bug: When using openwith, script extension loading seems to bug out. Proof: Reload Extension is locked & ext. script custom option is first in menu.
# -/ Check why openwith blocks local extensions from working.
# -/ Have file explorer path start at session location.
# -/ Bug: Fix save notice for after deleting a mod.
# -/ Bug: Priority order is starting at 2 if only 1 plugin-free type variant exists in the ML.
# -/ Bug: Extension reload not reloading extenison when app opened through openwith.
# -/ Bug: Fix import window scaling for buttons.
# -/ Bug: Individual mod import text & icons are not appearing.
# --- Uncompleted
# -?Can't remember why:Mod descriptions/install instructions? Add hidden fields for game extensions that can be edited but don't appear in mod tree.
# - Add a feature for mod link cleaning that detects link/name similarities and pings user.
# - Add alternative link text-fields to all mod fields.
# - Add alt script loading options to game extensions and to extension menu.
# - Autosave, a session backup feature.
# - Add support for multi-mod incompatibility patches.
# - Add unpatched incompatiblity description field with instructions on how to resolve.
# - Add an auto detect feature for mod patches that fills in the required mods section on its own.
# - For compatibility mods check for existing link before assigning them in auto sort feature.
# - Investigate portability to Godot 4.
# -?Need alt device to test? Auto File Association with .mplan
# - Add a requirements detection to mod import window.
# - Add support for priority-files type.
# - Rework auto sort for plugin to file priority differences.
# - Add lock feature for mod LO/POs in the auto sort.
# - Add a follow up step to auto sort that places patches next to the lowest req. mod in the LO. (Low LO = higher LO value). Start at 0 LO and work upwards checking reqs. and compats. Use the adjust feature to do it.
# --- Perma Delayed
# - Add the recolor option to mod menu.
# - Rework popup management system using the metadata field for items. T_T whyyyyy
# - ModTreeManager: Add separator support.
# - Add an edit feature to resources.
# --- Cancelled
# -?Not necessary? Create a bool mod field.
