import json
import os
import plistlib
import sys
from datetime import datetime, timezone


def main() -> None:
    output = sys.argv[1]
    plist_path = os.environ.get("INFO_PLIST", "LiveContainer/Info.plist")
    with open(plist_path, "rb") as handle:
        info = plistlib.load(handle)

    repository = os.environ["REPOSITORY"]
    tag = os.environ.get("RELEASE_TAG", "nightly")
    version = os.environ["VERSION"]
    build = os.environ["BUILD"]
    size = int(os.environ["IPA_SIZE"])
    ipa_url = f"https://github.com/{repository}/releases/download/{tag}/LiveContainer%2BSideStore.ipa"
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

    version_entry = {
        "version": version,
        "buildVersion": build,
        "date": now,
        "localizedDescription": "LiveContainer SideStore内蔵版の最新ビルドです。",
        "downloadURL": ipa_url,
        "size": size,
    }
    source = {
        "name": "NContainer",
        "identifier": "com.nezumi0627.ncontainer.source",
        "website": f"https://github.com/{repository}",
        "subtitle": "NContainer SideStore embedded build",
        "description": "NContainerのSideStore内蔵版を配布する公式ソースです。",
        "iconURL": f"https://raw.githubusercontent.com/{repository}/main/screenshots/livecontainer_icon.png",
        "apps": [{
            "beta": True,
            "name": "NContainer",
            "bundleIdentifier": info["CFBundleIdentifier"],
            "developerName": "nezumi0627",
            "subtitle": "LiveContainer SideStore embedded build",
            "version": version,
            "versionDate": now,
            "versionDescription": "LiveContainer SideStore内蔵版",
            "downloadURL": ipa_url,
            "localizedDescription": "LiveContainer SideStore内蔵版",
            "iconURL": f"https://raw.githubusercontent.com/{repository}/main/screenshots/livecontainer_icon.png",
            "size": size,
            "versions": [version_entry],
        }],
    }
    with open(output, "w", encoding="utf-8") as handle:
        json.dump(source, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


if __name__ == "__main__":
    main()
