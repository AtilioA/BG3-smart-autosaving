import os
import shutil
import subprocess
import zipfile
import xml.etree.ElementTree as ET

UUID = "0c8bb2e9-aa96-4de7-b793-a733d68ee6f0"
VERSION = "2.0.0"
INT64_VERSION = "36028799166447616"
MOD_NAME = "Smart Autosaving"
OUTPUT_PATH = "output"

# Mod options
autosave_intervals = [5, 10, 15]  # in minutes
event_options = {
    'dialogue': [True, False],
    'trade': [True, False],
    'combat': [True, False]
}

def stringify_events(events: list):
    if len(events) > 1:
        return ", ".join(events[:-1]) + " and " + events[-1]
    else:
        return events[0]

def generate_config_file(output_dir, interval, events: dict):
    """Generates the config.lua file for the mod variation."""
    file_name = "config.lua"
    with open(os.path.join(output_dir, file_name), 'w') as file:
        file.write("local Config = {}\n\n")
        file.write(f"Config.AUTOSAVING_PERIOD = {interval} * {60} -- {interval} minutes\n")
        file.write(f"Config.EVENTS = {{\n")
        file.write(f"    dialogue = {str(events['dialogue']).lower()}, -- Postpone autosaving if the player is in dialogue\n")
        file.write(f"    trade = {str(events['trade']).lower()}, -- Postpone autosaving if the player is trading/bartering\n")
        file.write(f"    combat = {str(events['combat']).lower()}, -- Postpone autosaving if the player is in combat\n")
        file.write(f"    lockpicking = true -- Always postpone during lockpicking\n")
        file.write("}\n\n")
        file.write("return Config\n")

def create_mod_variations(interval, events: dict):
    """Creates a mod variation folder with the necessary files."""
    # Include only those event names where the value is True
    included_events = [event for event, included in events.items() if included]
    if len(included_events) == 0:
        included_events.append("no_postponing")
    # Construct folder name with included events
    folder_name = f"{MOD_NAME} - {interval}min"
    mod_path = os.path.join(OUTPUT_PATH, folder_name)
    os.makedirs(mod_path, exist_ok=True)
    subfolder_name = f"{interval}min_{'_'.join(included_events)}"
    subfolder_path = os.path.join(mod_path, subfolder_name)

    # Copy Lua and Config.json files
    mods_folder_path = os.path.join(subfolder_path, "Mods")
    proper_mod_folder_path = os.path.join(mods_folder_path, subfolder_name)
    script_extender_path = os.path.join(proper_mod_folder_path, "ScriptExtender")
    lua_path = os.path.join(script_extender_path, "Lua")

    os.makedirs(mods_folder_path, exist_ok=True)
    os.makedirs(proper_mod_folder_path, exist_ok=True)
    os.makedirs(lua_path, exist_ok=True)

    shutil.copy("SmartAutosaving/ScriptExtender/Config.json", script_extender_path)
    shutil.copy("SmartAutosaving/ScriptExtender/Lua/BootstrapServer.lua", lua_path)

    # Create the config.lua file
    generate_config_file(lua_path, interval, events)

    # Create meta.lsx for this mod variation
    create_meta_lsx(subfolder_name, proper_mod_folder_path, interval, included_events)

    # Package the mod into a .pak file
    # Get absolute path to the mod folder
    mod_abs_path = os.path.abspath(subfolder_path)
    mod_name = os.path.basename(subfolder_path)
    pak_path = package_mod(mod_abs_path, mod_name)

    zip_mod_files(pak_path, mod_name)

    return mod_path

def create_meta_lsx(folder, output_dir, interval, events):
    """Creates the meta.lsx file for the mod variation."""
    meta_template_path = "SmartAutosaving/meta.lsx"
    tree = ET.parse(meta_template_path)
    root = tree.getroot()

    if events[0] == "no_postponing":
        name = f"Smart Autosaving - {interval} minutes | No postponing"
        description = f"Autosaves every {str(interval)} minutes, without postponing."
    else:
        name = f"Smart Autosaving - {interval} minutes | {stringify_events(events)}"
        description = f"Autosaves every {str(interval)} minutes, but postpones during {stringify_events(events)}."

    # Update meta.lsx values
    module_info = root.find(".//node[@id='ModuleInfo']")
    module_info.find(".//attribute[@id='Name']").set('value', name)
    module_info.find(".//attribute[@id='Description']").set('value', description)
    module_info.find(".//attribute[@id='UUID']").set('value', UUID)
    module_info.find(".//attribute[@id='Version']").set('value', str(INT64_VERSION))
    module_info.find(".//attribute[@id='Folder']").set('value', folder)

    # Write the updated meta.lsx file
    new_meta_file = os.path.join(output_dir, "meta.lsx")
    tree.write(new_meta_file, encoding="UTF-8", xml_declaration=True)

def clear_paks_from_output_folder():
    """Clears the output folder of all .pak files, recursively."""
    for root, dirs, files in os.walk(OUTPUT_PATH):
        for file in files:
            if file.endswith(".pak"):
                os.remove(os.path.join(root, file))

def run_divine_command(source_path, destination_path):
    """Runs the divine command to create a .pak file from the mod folder."""
    try:
        subprocess.run([
            "divine",
            "--action", "create-package",
            "--game", "bg3",
            "--source", source_path,
            "--destination", destination_path,
            "--compression-method", "lz4"
        ], check=True)
        print(f"Successfully created .pak file: {destination_path}")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while creating the .pak file: {e}")

def package_mod(mod_path, mod_name):
    """Packages a mod path into a .pak file."""
    destination_pak = os.path.join(mod_path, mod_name + ".pak")

    # Clean the output folder of all previous .pak files
    clear_paks_from_output_folder()

    # Run divine command to create .pak file
    run_divine_command(mod_path, destination_pak)

    return destination_pak

def zip_mod_files(pak_path, mod_name):
    """Zips the .pak files into a .zip file ready to be imported with BG3MM. Writes the .zip file to .pak file's directory."""
    # Create a .zip file with the same name as the .pak file

    zip_path = os.path.join(os.path.dirname(pak_path) + ".zip")
    pak_path = os.path.join(os.path.dirname(pak_path), mod_name + ".pak")

    with zipfile.ZipFile(zip_path, 'w') as zip_file:
        zip_file.write(pak_path, arcname=os.path.basename(pak_path))

    shutil.rmtree(os.path.dirname(pak_path), ignore_errors=True)
    print(f"Successfully created .zip file: {zip_path}")

def generate_and_package_mods():
    """Generates and packages all mod variations."""
    for interval in autosave_intervals:
        for dialogue in event_options['dialogue']:
            for trade in event_options['trade']:
                for combat in event_options['combat']:
                    events = {}
                    events['dialogue'] = dialogue
                    events['trade'] = trade
                    events['combat'] = combat

                    # Create mod variation folder with necessary files
                    create_mod_variations(interval, events)

    # Copy the zip_README.txt file to the output folder
    shutil.copy("zip_README.txt", os.path.join(OUTPUT_PATH, "README.txt"))

    # This will create a default mod variation if the user does not pick a specific one from within the zip file.
    shutil.unpack_archive(os.path.join(OUTPUT_PATH, f"{MOD_NAME} - 10min", "10min_dialogue_trade_combat.zip"), OUTPUT_PATH)

    # Zip everything into a single archive to be released (e.g. on Nexus)
    shutil.make_archive(f"Smart Autosaving {VERSION}", 'zip', OUTPUT_PATH)

def cleanup():
    """Cleans up the output folder and main archive."""
    shutil.rmtree(OUTPUT_PATH, ignore_errors=True)
    if os.path.exists(f"Smart Autosaving {VERSION}.zip"):
        os.remove(f"Smart Autosaving {VERSION}.zip")

if __name__ == "__main__":
    cleanup()
    generate_and_package_mods()
