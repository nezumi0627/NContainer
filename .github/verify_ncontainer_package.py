import argparse
import json
import os
import plistlib
import sys


EXPECTED_BUNDLE_ID = "com.kdt.livecontainer"
EXPECTED_SIDESTORE_GROUP = "group.com.SideStore.SideStore"


def fail(message: str) -> None:
    raise SystemExit(f"NContainer package validation failed: {message}")


def validate_plist(path: str) -> None:
    with open(path, "rb") as handle:
        info = plistlib.load(handle)

    bundle_id = info.get("CFBundleIdentifier")
    if bundle_id != EXPECTED_BUNDLE_ID:
        fail(f"CFBundleIdentifier is {bundle_id!r}; expected {EXPECTED_BUNDLE_ID!r}")

    app_groups = info.get("ALTAppGroups", [])
    if EXPECTED_SIDESTORE_GROUP not in app_groups:
        fail(f"ALTAppGroups does not contain {EXPECTED_SIDESTORE_GROUP!r}")


def validate_source(path: str) -> None:
    with open(path, "r", encoding="utf-8") as handle:
        source = json.load(handle)

    apps = source.get("apps")
    if not isinstance(apps, list) or not apps:
        fail("source does not contain an app")

    app = apps[0]
    if app.get("bundleIdentifier") != EXPECTED_BUNDLE_ID:
        fail("source bundleIdentifier is not the stable LiveContainer identifier")

    download_url = app.get("downloadURL", "")
    if "LiveContainer%2BSideStore.ipa" not in download_url:
        fail("source does not point to the SideStore embedded IPA")


def validate_payload(payload_root: str) -> None:
    app_root = os.path.join(payload_root, "LiveContainer.app")
    if not os.path.isdir(app_root):
        fail(f"missing app bundle: {app_root}")

    validate_plist(os.path.join(app_root, "Info.plist"))

    sidestore_binary = os.path.join(
        app_root, "Frameworks", "SideStoreApp.framework", "SideStore"
    )
    if not os.path.isfile(sidestore_binary):
        fail("embedded SideStore executable is missing")

    live_process = os.path.join(app_root, "PlugIns", "LiveProcess.appex")
    if not os.path.isdir(live_process):
        fail("LiveProcess.appex is missing")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--app-plist")
    parser.add_argument("--source")
    parser.add_argument("--payload-root")
    args = parser.parse_args()

    if not any((args.app_plist, args.source, args.payload_root)):
        parser.error("at least one validation target is required")
    if args.app_plist:
        validate_plist(args.app_plist)
    if args.source:
        validate_source(args.source)
    if args.payload_root:
        validate_payload(args.payload_root)

    print("NContainer package validation passed")


if __name__ == "__main__":
    main()
