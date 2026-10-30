# ZIPWATCH Finder

Flutter app that connects to the ESP32 "ZIPWATCH-FINDER" over BLE and sends `FIND` / `STOP`
to ring the buzzer. The APK is built by GitHub Actions - no local Android setup needed.

## Build the APK
1. Create a GitHub repo and push this folder (`git init && git add . && git commit -m init && git push`).
2. Open the **Actions** tab -> **Build Android APK** (runs on every push; or press *Run workflow*).
3. When it finishes, download **ZIPWATCH-Finder-apk** from the run's *Artifacts* and install the APK.
4. Optional: `git tag v1.0.0 && git push --tags` attaches the APK to a GitHub Release.

## Local run (optional)
    flutter create --platforms=android .   # once, generates android/
    python3 tool/patch_android.py
    dart run flutter_launcher_icons
    flutter run
