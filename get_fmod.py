import getpass
import os
import shutil
import sys
import tempfile

import requests

fmod_version = "20400"
fmod_dir = "fmod"

if len(sys.argv) != 2:
    sys.exit("usage: get-fmod <platform>")

platform = sys.argv[1]

user = input("FMOD username: ")
password = getpass.getpass("FMOD password: ")

fmodlink = "https://www.fmod.com/api-login"
downloadlink = "https://www.fmod.com/api-get-download-link"

if platform == "linux":
    # linux
    path = "Linux"
    filename = f"fmodstudioapi{fmod_version}linux.tar.gz"
    extract = True
elif platform == "html5":
    # HTML5 / emscripten
    path = "HTML5"
    filename = f"fmodstudioapi{fmod_version}html5.zip"
    extract = True
elif platform == "macos":
    # OS X
    path = "Mac"
    filename = f"fmodstudioapi{fmod_version}mac-installer.dmg"
    extract = False
elif platform == "windows":
    # Windows...
    path = "Windows"
    filename = f"fmodstudioapi{fmod_version}win-installer.exe"
    extract = False
elif platform == "android":
    # Android...
    path = "Android"
    filename = f"fmodstudioapi{fmod_version}android.tar.gz"
    extract = True
elif platform == "ios":
    # iOS...
    path = "iOS"
    filename = f"fmodstudioapi{fmod_version}ios-installer.dmg"
    extract = False
else:
    sys.exit(f"unknown platform: {platform}")

dest = os.path.join(fmod_dir, platform)
download = os.path.join(fmod_dir, filename)

if extract and os.path.exists(dest):
    sys.exit(f"{dest} already exists")

# First login and get a token!
response = requests.post(fmodlink, auth=(user, password))
token = response.json()["token"]

print("Received token from FMOD login API.")

# Next request a download link using the token!
response = requests.get(
    downloadlink,
    params={
        "path": f"files/fmodstudio/api/{path}/",
        "filename": filename,
        "user": user,
    },
    headers={"Authorization": f"Bearer {token}"},
)

url = response.json()["url"]

# Download FMOD!
print("Downloading FMOD using the requested download link.")
os.makedirs(fmod_dir, exist_ok=True)

with requests.get(url, stream=True) as response:
    response.raise_for_status()

    with open(download, "wb") as f:
        shutil.copyfileobj(response.raw, f)

if extract:
    print(f"Extracting into {dest}.")

    with tempfile.TemporaryDirectory() as tmp:
        shutil.unpack_archive(download, tmp)
        [root] = os.listdir(tmp)
        shutil.move(os.path.join(tmp, root), dest)

    os.remove(download)
