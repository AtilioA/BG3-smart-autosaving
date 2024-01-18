import os
import shutil
import subprocess
import xml.etree.ElementTree as ET

UUID = "0c8bb2e9-aa96-4de7-b793-a733d68ee6f0"
VERSION = "2.0.0"
INT64_VERSION = "72057594037927936"
MOD_NAME = "Smart Autosaving"

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
    print(os.path.abspath(mod_path))
    destination_pak = os.path.abspath(os.path.join(mod_name + ".pak"))

    # Run divine command to create .pak file
    run_divine_command(os.path.abspath(mod_path), destination_pak)

    return destination_pak


def cleanup():
    if os.path.exists(f"Smart Autosaving {VERSION}.zip"):
        print("Cleaning .zip | ", end="")
        os.remove(f"Smart Autosaving {VERSION}.zip")
    if os.path.exists(f"Smart Autosaving.pak"):
        print("Cleaning .pak")
        os.remove(f"Smart Autosaving.pak")


if __name__ == "__main__":
    cleanup()

    pak_path = package_mod("./Smart Autosaving/", MOD_NAME)
    shutil.make_archive(f"Smart Autosaving {VERSION}", "zip", os.path.dirname(pak_path), os.path.basename(pak_path))
