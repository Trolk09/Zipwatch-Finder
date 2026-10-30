"""Patches the freshly generated android/ folder: BLE permissions + app label."""
import re, pathlib

p = pathlib.Path("android/app/src/main/AndroidManifest.xml")
s = p.read_text()

perms = """    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
"""
if "BLUETOOTH_SCAN" not in s:
    s = s.replace("<application", perms + "    <application", 1)

s = re.sub(r'android:label="[^"]*"', 'android:label="ZIPWATCH Finder"', s, count=1)
p.write_text(s)
print("Manifest patched")
