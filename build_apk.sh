#!/usr/bin/env bash
# Builds release APK with timestamped name: Humora-Patient(ddMMyyyyHHmm).apk
# Usage: ./build_apk.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

flutter clean
flutter pub get
flutter build apk

RELEASE_DIR="$ROOT/build/app/outputs/apk/release"
FLUTTER_DIR="$ROOT/build/app/outputs/flutter-apk"
mkdir -p "$FLUTTER_DIR"

GRADLE_APK="$(find "$RELEASE_DIR" -maxdepth 1 -name 'Humora-Patient(*.apk' -type f 2>/dev/null | head -1)"

if [ -n "$GRADLE_APK" ]; then
  APK_NAME="$(basename "$GRADLE_APK")"
  cp -f "$GRADLE_APK" "$FLUTTER_DIR/$APK_NAME"
elif [ -f "$FLUTTER_DIR/app-release.apk" ]; then
  TIMESTAMP="$(date +%d%m%Y%H%M)"
  APK_NAME="Humora-Patient(${TIMESTAMP}).apk"
  cp -f "$FLUTTER_DIR/app-release.apk" "$FLUTTER_DIR/$APK_NAME"
else
  echo "Error: Release APK not found." >&2
  exit 1
fi

rm -f "$FLUTTER_DIR/app-release.apk"

echo ""
echo "✓ Release APK: $FLUTTER_DIR/$APK_NAME"
