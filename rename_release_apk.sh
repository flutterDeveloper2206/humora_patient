#!/usr/bin/env bash
# Run after `flutter build apk` to copy/rename to Humora-Patient(ddMMyyyyHHmm).apk
# Usage: ./rename_release_apk.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR="$ROOT/build/app/outputs/apk/release"
FLUTTER_DIR="$ROOT/build/app/outputs/flutter-apk"

GRADLE_APK="$(find "$RELEASE_DIR" -maxdepth 1 -name 'Humora-Patient(*.apk' -type f 2>/dev/null | head -1)"

if [ -n "$GRADLE_APK" ]; then
  APK_NAME="$(basename "$GRADLE_APK")"
  mkdir -p "$FLUTTER_DIR"
  cp -f "$GRADLE_APK" "$FLUTTER_DIR/$APK_NAME"
elif [ -f "$FLUTTER_DIR/app-release.apk" ]; then
  TIMESTAMP="$(date +%d%m%Y%H%M)"
  APK_NAME="Humora-Patient(${TIMESTAMP}).apk"
  mv "$FLUTTER_DIR/app-release.apk" "$FLUTTER_DIR/$APK_NAME"
else
  echo "Error: No release APK found. Run flutter build apk first." >&2
  exit 1
fi

rm -f "$FLUTTER_DIR/app-release.apk"
echo "✓ Release APK: $FLUTTER_DIR/$APK_NAME"
