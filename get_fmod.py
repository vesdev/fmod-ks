import getpass
import glob
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

keep_common = [
    "api/core/inc/*.h",
    "api/studio/inc/*.h",
    "doc/LICENSE.TXT",
    "doc/revision.txt",
]

keep = {
    "linux": [
        "api/core/lib/x86_64/libfmod.so*",
        "api/core/lib/arm64/libfmod.so*",
        "api/studio/lib/x86_64/libfmodstudio.so*",
        "api/studio/lib/arm64/libfmodstudio.so*",
    ],
    "html5": [
        "api/studio/lib/browser/*/c_cpp/fmodstudio*.a",
    ],
    "android": [
        "api/core/lib/**",
        "api/studio/lib/**",
    ],
}


def trim(src, dst):
    for pattern in keep_common + keep[platform]:
        for rel in glob.glob(pattern, root_dir=src, recursive=True):
            src_path = os.path.join(src, rel)
            dst_path = os.path.join(dst, rel)

            if os.path.isdir(src_path) and not os.path.islink(src_path):
                continue

            os.makedirs(os.path.dirname(dst_path), exist_ok=True)

            if os.path.islink(src_path):
                os.symlink(os.readlink(src_path), dst_path)
            else:
                shutil.copy2(src_path, dst_path)


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
        trim(os.path.join(tmp, root), dest)

    os.remove(download)
