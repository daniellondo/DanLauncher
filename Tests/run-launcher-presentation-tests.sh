#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT HUP INT TERM
swiftc -swift-version 5 \
  "$ROOT/WidgetLauncher/LauncherPresentation.swift" \
  "$ROOT/Tests/LauncherPresentationTests.swift" \
  -o "$WORK/launcher-presentation-tests"
"$WORK/launcher-presentation-tests"
swiftc -swift-version 5 -typecheck \
  "$ROOT/WidgetLauncher/LauncherPresentation.swift" \
  "$ROOT/WidgetLauncher/AppStoreArtwork.swift"
swiftc -frontend -parse "$ROOT"/WidgetLauncher/*.swift
printf '%s\n' 'PASS: Foundation helper typecheck and Swift source parsing. This is NOT an iOS build.'
